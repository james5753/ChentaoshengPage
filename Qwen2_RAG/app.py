from flask import Flask, request, jsonify
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import DashScopeEmbeddings
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough, RunnableParallel
from langchain_community.llms import Tongyi
import os
from collections import defaultdict

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
        merged_docs = defaultdict(lambda: {"body_urls": set(), "rendering_urls": set()})
        for doc in result['context']:
            title = doc.metadata.get('title', '无标题')
            merged_docs[title]["body_urls"].update(doc.metadata.get('body_urls', []))
            merged_docs[title]["rendering_urls"].update(doc.metadata.get('rendering_urls', []))

        # 格式化文档信息
        formatted_docs = []
        for i, (title, info) in enumerate(merged_docs.items(), 1):
            doc_info = {
                "title": title,
                "body_urls": sorted(info["body_urls"]),
                "rendering_urls": sorted(info["rendering_urls"])
            }
            formatted_docs.append(doc_info)

        response = {
            "question": result['question'],
            "answer": result['answer'],
            "documents": formatted_docs
        }

        return jsonify(response)

    except Exception as e:
        # Log the error here if you have logging set up
        print(f"An error occurred: {str(e)}")
        return jsonify({"error": "An internal error occurred"}), 500

if __name__ == '__main__':
    app.run(debug=True)