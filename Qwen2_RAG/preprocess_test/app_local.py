from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import DashScopeEmbeddings
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough, RunnableParallel
from langchain_community.llms import Tongyi
import os
from collections import defaultdict
from operator import itemgetter
import re

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

def query(question):
    try:
        result = rag_chain_with_source.invoke(question)

        # 处理输出
        merged_docs = defaultdict(lambda: {"content": "", "m3_url": ""})
        for doc in result['context']:
            title = doc.metadata.get('title', '无标题')
            merged_docs[title]["content"] += doc.page_content + " "
            merged_docs[title]["m3_url"] = doc.metadata.get('m3_url', '')

        # 格式化文档信息
        formatted_docs = []
        for title, info in merged_docs.items():
            doc_info = {
                "title": title,
                "content": info["content"].strip(),
                "m3_url": info["m3_url"]
            }
            formatted_docs.append(doc_info)

        response = {
            "question": result['question'],
            "answer": result['answer'],
            "documents": formatted_docs
        }

        return response

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return {"error": "An internal error occurred"}

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

# 测试函数
def test_query():
    question = "毛泽东和陈騊声有交集吗"
    result = query(question)
    print("Question:", result['question'])
    print("Answer:", add_name_markers(result['answer']))
    print("\nRelevant Documents:")

    for i, doc in enumerate(result['documents']):
        if i >= 2:  # 只显示前两个文档
            break
        print(f"标题: {doc['title']}")
        print(f"Mirador 3 URL: {doc['m3_url']}")
        print()

if __name__ == '__main__':
    test_query()