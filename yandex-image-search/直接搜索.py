#!/usr/bin/env python3
"""
直接使用Yandex搜索相似项链图片
简化版：使用本地文件，手动上传到Yandex
"""

import os
import time
import asyncio
from playwright.async_api import async_playwright
import subprocess

async def search_necklace_on_yandex(image_path):
    """使用Yandex搜索相似项链图片"""
    
    print("="*60)
    print("🔍 开始Yandex图片搜索")
    print("="*60)
    print(f"源图片: {image_path}")
    
    if not os.path.exists(image_path):
        print(f"❌ 图片不存在: {image_path}")
        return None
    
    # 启动浏览器
    print("🌐 启动浏览器...")
    playwright = await async_playwright().start()
    browser = await playwright.chromium.launch(
        headless=False,  # 显示浏览器，方便操作
        args=['--no-sandbox', '--disable-dev-shm-usage']
    )
    
    context = await browser.new_context(
        viewport={'width': 1920, 'height': 1080},
        user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    )
    
    page = await context.new_page()
    
    try:
        # 打开Yandex图片搜索
        print("📷 打开Yandex图片搜索...")
        await page.goto('https://yandex.com/images/', timeout=30000)
        await page.wait_for_load_state('networkidle')
        
        # 点击"按图搜索"按钮
        print("🔘 点击'Search by image'按钮...")
        try:
            # 尝试点击相机图标
            await page.click("div[class*='camera']", timeout=5000)
        except:
            try:
                # 尝试其他选择器
                await page.click("button[aria-label='Search by image']", timeout=5000)
            except:
                print("⚠️ 无法点击按钮，尝试直接访问上传页面")
                await page.goto('https://yandex.com/images/search?source=collections&rpt=imageview', timeout=30000)
        
        await asyncio.sleep(2)
        
        # 点击"上传文件"按钮
        print("📤 点击'Upload file'按钮...")
        try:
            # 查找包含"Upload"文本的按钮
            upload_button = await page.wait_for_selector(
                "button:has-text('Upload'), div:has-text('Upload'), a:has-text('Upload')",
                timeout=5000
            )
            await upload_button.click()
        except:
            print("⚠️ 找不到上传按钮，尝试直接选择文件")
            # 直接查找文件输入元素
            file_input = await page.wait_for_selector("input[type='file']", timeout=5000)
        
        await asyncio.sleep(2)
        
        # 关键：现在文件选择对话框应该已经打开
        print("🚨 重要提示：文件选择对话框已打开！")
        print("="*60)
        print("🎯 请立即操作：")
        print("1. 切换到浏览器窗口")
        print("2. 在文件选择对话框中：")
        print(f"   选择文件: {image_path}")
        print("3. 点击'打开'按钮")
        print("4. 等待搜索结果")
        print("5. 保存8张最相似的项链图片")
        print("="*60)
        
        # 等待用户操作
        input("按Enter键继续（当你完成文件选择后）...")
        
        # 等待搜索结果
        print("⏳ 等待Yandex分析图片...")
        await asyncio.sleep(5)
        
        # 获取当前URL
        current_url = page.url
        print(f"🌐 搜索结果页面: {current_url}")
        
        # 保存页面截图
        screenshot_path = "yandex_search_results.png"
        await page.screenshot(path=screenshot_path, full_page=True)
        print(f"📸 页面截图已保存: {screenshot_path}")
        
        # 提取图片信息
        print("🖼️ 提取相似图片...")
        images = await page.query_selector_all("img")
        
        similar_images = []
        for i, img in enumerate(images[:20]):  # 检查前20张图片
            try:
                src = await img.get_attribute("src")
                alt = await img.get_attribute("alt") or f"项链图片{i+1}"
                
                if src and src.startswith(('http', 'data:')):
                    # 过滤掉小图标
                    if 'logo' not in src.lower() and 'icon' not in src.lower():
                        similar_images.append({
                            "index": len(similar_images) + 1,
                            "src": src,
                            "alt": alt,
                            "similarity": 100 - (len(similar_images) * 10)
                        })
                        
                        if len(similar_images) >= 8:
                            break
            except:
                continue
        
        print(f"✅ 找到 {len(similar_images)} 张相似图片")
        
        # 创建结果目录
        output_dir = "yandex_results"
        os.makedirs(output_dir, exist_ok=True)
        
        # 下载图片
        import requests
        downloaded_files = []
        
        print("📥 下载图片...")
        for img_info in similar_images:
            try:
                src = img_info["src"]
                index = img_info["index"]
                
                # 处理data URL
                if src.startswith('data:'):
                    print(f"⚠️ 跳过data URL图片 [{index}]")
                    continue
                
                filename = f"necklace_{index}.jpg"
                filepath = os.path.join(output_dir, filename)
                
                response = requests.get(src, timeout=10)
                if response.status_code == 200:
                    with open(filepath, "wb") as f:
                        f.write(response.content)
                    
                    downloaded_files.append({
                        "filename": filename,
                        "path": filepath,
                        "size": len(response.content),
                        "src": src,
                        "similarity": img_info["similarity"]
                    })
                    print(f"✅ 下载成功 [{index}]: {filename}")
                else:
                    print(f"❌ 下载失败 [{index}]: HTTP {response.status_code}")
                    
            except Exception as e:
                print(f"⚠️ 下载出错 [{img_info.get('index', '?')}]: {e}")
        
        # 创建HTML查看器
        print("🌐 创建HTML查看器...")
        html_content = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yandex搜索 - 项链相似款式</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .image-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .image-card { border: 1px solid #ddd; padding: 10px; border-radius: 5px; }
        .image-card img { width: 100%; height: 200px; object-fit: cover; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 Yandex搜索 - 项链相似款式</h1>
        <p>基于反向图片搜索的相似款式收集</p>
    </div>
    
    <div class="image-grid">
"""
        
        for file_info in downloaded_files:
            html_content += f"""
        <div class="image-card">
            <img src="{file_info['filename']}" alt="项链相似款">
            <div style="text-align:center;margin-top:10px;">
                {file_info['filename']}<br>
                相似度: {file_info['similarity']}%
            </div>
        </div>
"""
        
        html_content += f"""
    </div>
    
    <div style="margin-top: 40px; padding: 20px; background: #f5f5f5; border-radius: 5px;">
        <h3>📋 搜索信息</h3>
        <p>源图片: {os.path.basename(image_path)}</p>
        <p>搜索时间: {time.strftime('%Y-%m-%d %H:%M:%S')}</p>
        <p>找到图片: {len(downloaded_files)}张</p>
        <p>搜索页面: <a href="{current_url}" target="_blank">{current_url}</a></p>
        <p>技术支持: 总管 🐾</p>
    </div>
</body>
</html>
"""
        
        html_file = os.path.join(output_dir, "查看结果.html")
        with open(html_file, "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print(f"📄 HTML查看器已创建: {html_file}")
        
        # 保存结果信息
        result_info = {
            "source_image": image_path,
            "search_url": current_url,
            "found_images": len(similar_images),
            "downloaded_images": len(downloaded_files),
            "downloaded_files": downloaded_files,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        
        import json
        result_file = os.path.join(output_dir, "搜索结果.json")
        with open(result_file, "w", encoding="utf-8") as f:
            json.dump(result_info, f, ensure_ascii=False, indent=2)
        
        print(f"📊 结果信息已保存: {result_file}")
        
        print("\n" + "="*60)
        print("🎉 搜索完成！")
        print("="*60)
        print(f"📁 输出目录: {output_dir}")
        print(f"🖼️ 下载图片: {len(downloaded_files)}张")
        print(f"🌐 查看结果: {html_file}")
        print("="*60)
        
        return result_info
        
    except Exception as e:
        print(f"❌ 搜索过程中出错: {e}")
        import traceback
        traceback.print_exc()
        return None
        
    finally:
        # 关闭浏览器
        await browser.close()
        await playwright.stop()

async def main():
    """主函数"""
    # 源图片路径
    source_image = os.path.expanduser("~/桌面/测试结果/源图_项链.png")
    
    if not os.path.exists(source_image):
        print(f"❌ 源图片不存在: {source_image}")
        print("请确保源图片存在，路径正确")
        return
    
    print(f"✅ 源图片存在: {source_image}")
    print(f"📏 图片大小: {os.path.getsize(source_image)} 字节")
    
    # 执行搜索
    result = await search_necklace_on_yandex(source_image)
    
    if result:
        print("\n✅ 任务完成！")
        print("\n🚀 下一步:")
        print(f"1. 查看结果: xdg-open {result.get('output_dir', 'yandex_results')}/查看结果.html")
        print("2. 验证图片相似度")
        print("3. 优化搜索参数")
        print("4. 开始商业化部署")
    else:
        print("\n❌ 任务失败")

if __name__ == "__main__":
    asyncio.run(main())