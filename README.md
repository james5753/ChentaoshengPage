# 文件夹结构与说明
## preprocess_test文件夹
该文件夹下存储了多项预处理和测试用的程序，为了方便用户的测试与调试，故保留。
1. new_merged_jsonl.josnl文件，内存储了从Archivesspace中爬取的内容，并且已经封装成格式完整的chunk，每个chunk是一个json对象，包含有原文连接、标题和内容。具体的chunk分割和爬取程序不在此文件夹中，等待管理员后续更新。
2. test_API.py文件，用于测试API-Key是否能够正常使用以及有没有对应模型的权限，建议在正式测试之前运行一次。
3. Faiss_embedding.py文件，用于使用Qwen大模型对new_merged_jsonl.josnl文件Embedding，输出的结果保存在根目录下的testjsonl.faiss文件夹。
4. Qwen_test.py文件，在本地能够完整的跑的问答，并且对回复的格式进行了基本处理，效果与挂上API相同。回复格式在父文件夹的output_example.txt。
## app.py文件
这是我们的重点程序，使用Flask建立了API，可以在POSTMAN里面进行测试
- 下载并安装Postman并打开
- 创建一个新的POST请求，设置请求URL为 http://localhost:5000/query
- （在Headers中添加 Content-Type: application/json）
- **在Body中选择raw和JSON**，然后输入:

```jsx
{
"question": "陈騊声有什么兴趣爱好吗？"
}
```

点击Send发送请求，查看响应
