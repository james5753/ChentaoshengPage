from flask import Flask, request, jsonify
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import DashScopeEmbeddings
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough, RunnableParallel
from langchain_community.llms import Tongyi
import os
import re
app = Flask(__name__)

# 设置环境变量
qwen_api_key = "sk-e846a90875cd433a82111d6051a31af9"
os.environ["DASHSCOPE_API_KEY"] = qwen_api_key

# 初始化模型和向量存储
embeddings = DashScopeEmbeddings(model="text-embedding-v1", dashscope_api_key=qwen_api_key)
faiss_index = FAISS.load_local('testjsonl.faiss', embeddings, allow_dangerous_deserialization=True)
retriever = faiss_index.as_retriever()

template = """利用以下上下文回答最后的问题。如果不知道答案，就说不知道，不要试图编造答案。

{context}

Question: {question}

Helpful Answer:"""
prompt = PromptTemplate.from_template(template)

llm = Tongyi()

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain_from_docs = (
    RunnablePassthrough.assign(context=(lambda x: format_docs(x["context"])))
    | prompt
    | llm
    | StrOutputParser()
)

rag_chain_with_source = RunnableParallel(
    {"context": retriever, "question": RunnablePassthrough()}
).assign(answer=rag_chain_from_docs)

def load_name_links(file_path):
    name_links = {}
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            name, link = line.strip().split('\t')
            name_links[name] = link
    return name_links

def add_name_markers(text):
    name_links = load_name_links("name_links.txt")
    replaced_names = set()  # 用于跟踪已替换的名字
    
    for name, link in name_links.items():
        if name not in replaced_names:
            pattern = re.escape(name)
            replacement = f'@{name}@${link}$'
            if re.search(pattern, text):
                text = re.sub(pattern, replacement, text, count=1)
                replaced_names.add(name)
    
    return text

@app.route('/query', methods=['POST'])
def query():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json(silent=True)
    if data is None:
        return jsonify({"error": "Invalid JSON or empty request body"}), 400

    question = data.get('question')
    if not question:
        return jsonify({"error": "No question provided"}), 400

    try:
        result = rag_chain_with_source.invoke(question)

        # 处理输出
        formatted_docs = []
        seen_urls = set()  # 用于跟踪已经添加的URL
        for doc in result['context']:
            m3_url = doc.metadata.get('m3_url', '')
            if m3_url not in seen_urls:  # 检查是否已经添加过这个URL
                doc_info = {
                    "title": doc.metadata.get('title', 'header'),  # 使用'header'作为默认标题
                    "m3_url": m3_url
                }
                formatted_docs.append(doc_info)
                seen_urls.add(m3_url)  # 将URL添加到已见集合中
            
            if len(formatted_docs) == 2:  # 只保留前两个唯一的文档
                break

        response = {
            "question": result['question'],
            "answer": add_name_markers(result['answer']),
            "documents": formatted_docs
        }
        
        return jsonify(response)

    except Exception as e:
        # Log the error here if you have logging set up
        print(f"An error occurred: {str(e)}")
        return jsonify({"error": "An internal error occurred"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888)