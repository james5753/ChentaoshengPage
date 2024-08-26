import json
from tqdm import tqdm
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import DashScopeEmbeddings
from langchain.schema import Document

# 使用你的 API 密钥
qwen_api_key = "sk-e846a90875cd433a82111d6051a31af9"

# 创建嵌入模型
embeddings = DashScopeEmbeddings(
   model="text-embedding-v1", dashscope_api_key=qwen_api_key
)

# 加载 JSONL 文件
def load_jsonl(file_path):
    documents = []
    total_lines = sum(1 for _ in open(file_path, 'r', encoding='utf-8'))
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in tqdm(file, total=total_lines, desc="Loading JSONL"):
            data = json.loads(line)
            doc = Document(page_content=data['content'], metadata=data.get('metadata', {}))
            documents.append(doc)
    return documents

print("开始加载文档...")
documents = load_jsonl("new_merged_jsonl.jsonl")
print(f"加载完成，共 {len(documents)} 条文档")

print("开始创建 FAISS 索引...")
faiss_index = FAISS.from_documents(documents, embeddings)
print("FAISS 索引创建完成")

print("正在保存 FAISS 索引...")
faiss_index.save_local("testjsonl.faiss")
print("FAISS 索引保存完成")