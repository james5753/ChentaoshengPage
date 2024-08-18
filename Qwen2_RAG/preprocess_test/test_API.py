import dashscope
from dashscope import Generation

# 设置你的 API 密钥
dashscope.api_key = "sk-e846a90875cd433a82111d6051a31af9"


def test_qwen2():
    response = Generation.call(
        model='qwen2-72b-instruct',
        prompt='你好，请介绍一下杭州。',
        max_tokens=100
    )
    
    if response.status_code == 200:
        print("API 调用成功！")
        print("生成的文本：")
        print(response.output.text)
    else:
        print("API 调用失败")
        print(f"状态码: {response.status_code}")
        print(f"错误信息: {response.message}")

# 运行测试
test_qwen2()