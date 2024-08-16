"""環境配置：
pip install langchain-community
pip install langchain
pip install faiss-cpu
pip install dashscope
"""

from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import DashScopeEmbeddings
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
import os
from langchain_community.llms import Tongyi

qwen_api_key = "sk-e846a90875cd433a82111d6051a31af9"

embeddings = DashScopeEmbeddings(
   model="text-embedding-v1", dashscope_api_key=qwen_api_key
)
# 加载之前我们的向量数据库文件
faiss_index = FAISS.load_local('testjsonl.faiss', embeddings, allow_dangerous_deserialization=True)

# retriever = faiss_index.as_retriever(search_kwargs={"k": 2}) # search_kwargs参数为返回相似的结果个数,用这个方法可能无法使用
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

from langchain_core.runnables import RunnableParallel

# 构建请求模版，拼接从文档中找到的相似结果，构建上下文内容参数
rag_chain_from_docs = (
   RunnablePassthrough.assign(context=(lambda x: format_docs(x["context"])))
   | prompt
   | llm
   | StrOutputParser()
)

# 将用户的问题传递给上下文提示和模型，然后把输出的结果赋值给新的键（answer）
rag_chain_with_source = RunnableParallel(
 {"context": retriever, "question": RunnablePassthrough()}
).assign(answer=rag_chain_from_docs)

result = rag_chain_with_source.invoke("陈騊声有什么兴趣爱好吗？")

# 执行查询并打印结果
from collections import defaultdict

print(result)
print("")
print("------------------------------输出内容解析---------------------------")
# 这部分可以解析所有的输出内容，包括节选的内容，本部分只处理了连接，
print("问题:", result['question'])
print("\n回答:", result['answer'])
print("\n参考文档:")

# 使用字典来存储合并后的文档信息
merged_docs = defaultdict(lambda: {"body_urls": set(), "rendering_urls": set()})

for doc in result['context']:
    title = doc.metadata.get('title', '无标题')
    merged_docs[title]["body_urls"].update(doc.metadata.get('body_urls', []))
    merged_docs[title]["rendering_urls"].update(doc.metadata.get('rendering_urls', []))

# 输出合并后的文档信息
for i, (title, info) in enumerate(merged_docs.items(), 1):
    print(f"\n文档 {i}:")
    if title != '无标题':
        print(f"《{title}》")
    else:
        print(title)
    
    print("『文献原图』")
    for jpg in sorted(info["body_urls"]):
        print(jpg)
    
    print("『文献OCR』")
    for md in sorted(info["rendering_urls"]):
        print(md)
    
    print("")