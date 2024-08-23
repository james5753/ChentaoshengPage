import argparse
import json
import sys
from langchain_core.runnables import RunnableParallel
from collections import defaultdict
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import DashScopeEmbeddings
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
import os
from langchain_community.llms import Tongyi

CMD_RAG_QUERY = 1

qwen_api_key = "sk-e846a90875cd433a82111d6051a31af9"

embeddings = DashScopeEmbeddings(
   model="text-embedding-v1", dashscope_api_key=qwen_api_key
)

# 检查FAISS文件是否存在
if not os.path.exists('testjsonl.faiss'):
    raise FileNotFoundError("FAISS index file not found.")

try:
    faiss_index = FAISS.load_local('testjsonl.faiss', embeddings, allow_dangerous_deserialization=True)
except Exception as e:
    print(f"Error loading FAISS index: {e}")
    raise

retriever = faiss_index.as_retriever()

template = """利用以下上下文回答最后的问题。如果不知道答案，就说不知道，不要试图编造答案。

{context}

Question: {question}

Helpful Answer:"""
prompt = PromptTemplate.from_template(template)

os.environ["DASHSCOPE_API_KEY"] = qwen_api_key

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

def run(command):
    if command["cmd"] == CMD_RAG_QUERY:
        question = command["question"]
        try:
            result = rag_chain_with_source.invoke(question)
        except Exception as e:
            print(f"Error invoking rag_chain_with_source: {e}")
            raise
        response = {
            "question": result['question'],
            "answer": result['answer'],
            "documents": []
        }
        merged_docs = defaultdict(lambda: {"body_urls": set(), "rendering_urls": set()})
        for doc in result['context']:
            title = doc.metadata.get('title', '无标题')
            merged_docs[title]["body_urls"].update(doc.metadata.get('body_urls', []))
            merged_docs[title]["rendering_urls"].update(doc.metadata.get('rendering_urls', []))
        for title, info in merged_docs.items():
            response["documents"].append({
                "title": title,
                "body_urls": list(info["body_urls"]),
                "rendering_urls": list(info["rendering_urls"])
            })
        return response
    else:
        return {"error": "Unknown command."}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--uuid")
    args = parser.parse_args()
    stream_start = f"`S`T`R`E`A`M`{args.uuid}`S`T`A`R`T`"
    stream_end = f"`S`T`R`E`A`M`{args.uuid}`E`N`D`"
    while True:
        cmd = input()
        cmd = json.loads(cmd)
        try:
            result = run(cmd)
        except Exception as e:
            result = {"exception": e.__str__()}
        result = json.dumps(result)
        print(result)