#!/usr/bin/env python3
"""
Yandex图片搜索爬虫 - 免费版，无需API
使用Playwright进行浏览器自动化
"""

import os
import time
import json
import asyncio
from playwright.async_api import async_playwright
from urllib.parse import quote_plus

class YandexImageSearch:
    """Yandex图片搜索类"""
    
    def __init__(self, headless=False):
        self.headless = headless
        self.browser = None
        self.context = None
        self.page = None
        
    async def init_browser(self):
        """初始化浏览器"""
        playwright = await async_playwright().start()
        self.browser = await playwright.chromium.launch(
            headless=self.headless,
            args=['--no-sandbox', '--disable-dev-shm-usage']
        )
        self.context = await self.browser.new_context(
            viewport={'width': 1920, 'height': 1080},
            user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        )
        self.page = await self.context.new_page()
        
    async def search_by_image_url(self, image_url, max_results=8):
        """
        通过图片URL进行Yandex图片搜索
        Args:
            image_url: 图片的公网URL
            max_results: 最大返回结果数
        Returns:
            list: 相似图片信息列表
        """
        try:
            print(f"🔍 开始Yandex图片搜索: {image_url}")
            
            # 打开Yandex图片搜索
            await self.page.goto('https://yandex.com/images/', timeout=30000)
            await self.page.wait_for_load_state('networkidle')
            
            # 点击"按图搜索"按钮
            print("📷 点击'按图搜索'按钮...")
            try:
                # 尝试多种选择器
                selectors = [
                    "button[aria-label='Search by image']",
                    "div[class*='camera']",
                    "div[data-bem*='camera']",
                    "button:has-text('Search by image')",
                    "div[role='button']:has-text('Search by image')"
                ]
                
                for selector in selectors:
                    try:
                        camera_btn = await self.page.wait_for_selector(selector, timeout=5000)
                        if camera_btn:
                            await camera_btn.click()
                            print(f"✅ 使用选择器找到按钮: {selector}")
                            break
                    except:
                        continue
                else:
                    # 如果找不到，尝试通过XPath
                    await self.page.click("//div[contains(@class, 'camera')]")
                    
            except Exception as e:
                print(f"⚠️ 点击按钮失败，尝试直接访问上传页面: {e}")
                # 直接访问上传页面
                await self.page.goto('https://yandex.com/images/search?source=collections&rpt=imageview', timeout=30000)
            
            # 等待上传界面出现
            await asyncio.sleep(2)
            
            # 输入图片URL
            print("🔗 输入图片URL...")
            try:
                # 尝试找到URL输入框
                url_input = await self.page.wait_for_selector(
                    "input[placeholder*='URL']", 
                    timeout=10000
                )
                await url_input.fill(image_url)
                
                # 点击搜索按钮
                search_btn = await self.page.wait_for_selector(
                    "button:has-text('Search')", 
                    timeout=5000
                )
                await search_btn.click()
                
            except:
                # 备用方案：直接构造搜索URL
                print("🔄 使用备用方案：直接构造搜索URL")
                encoded_url = quote_plus(image_url)
                search_url = f"https://yandex.com/images/search?url={encoded_url}&rpt=imageview"
                await self.page.goto(search_url, timeout=30000)
            
            # 等待搜索结果
            print("⏳ 等待搜索结果...")
            await self.page.wait_for_load_state('networkidle')
            await asyncio.sleep(3)
            
            # 获取页面内容
            page_content = await self.page.content()
            
            # 提取相似图片
            print("🖼️ 提取相似图片...")
            similar_images = await self.extract_similar_images(max_results)
            
            return {
                "success": True,
                "source_image": image_url,
                "similar_images": similar_images,
                "result_count": len(similar_images),
                "search_url": self.page.url
            }
            
        except Exception as e:
            print(f"❌ Yandex搜索失败: {e}")
            return {
                "success": False,
                "error": str(e),
                "source_image": image_url
            }
    
    async def extract_similar_images(self, max_results=8):
        """从搜索结果页面提取相似图片"""
        images = []
        
        try:
            # 方法1: 通过CSS选择器提取
            image_elements = await self.page.query_selector_all(
                "div[class*='serp-item'], a[class*='serp-item'], div[class*='image']"
            )
            
            for i, element in enumerate(image_elements[:max_results*2]):
                try:
                    # 获取图片URL
                    img_element = await element.query_selector("img")
                    if img_element:
                        src = await img_element.get_attribute("src")
                        alt = await img_element.get_attribute("alt") or f"图片{i+1}"
                        
                        # 处理相对URL
                        if src and not src.startswith(('http', 'data:')):
                            if src.startswith('//'):
                                src = 'https:' + src
                            elif src.startswith('/'):
                                src = 'https://yandex.com' + src
                        
                        if src and src.startswith(('http', 'data:')):
                            images.append({
                                "index": len(images) + 1,
                                "src": src,
                                "alt": alt,
                                "similarity_score": 100 - (len(images) * 10)  # 简单评分
                            })
                            
                            if len(images) >= max_results:
                                break
                                
                except:
                    continue
            
            # 方法2: 如果方法1没找到，尝试其他选择器
            if len(images) < max_results:
                all_images = await self.page.query_selector_all("img")
                for img in all_images:
                    if len(images) >= max_results:
                        break
                    
                    try:
                        src = await img.get_attribute("src")
                        if src and src.startswith(('http', 'data:')):
                            # 过滤掉小图标
                            if 'logo' not in src.lower() and 'icon' not in src.lower():
                                alt = await img.get_attribute("alt") or f"图片{len(images)+1}"
                                images.append({
                                    "index": len(images) + 1,
                                    "src": src,
                                    "alt": alt,
                                    "similarity_score": 100 - (len(images) * 10)
                                })
                    except:
                        continue
            
            print(f"✅ 提取到 {len(images)} 张相似图片")
            return images
            
        except Exception as e:
            print(f"⚠️ 提取图片时出错: {e}")
            return images
    
    async def close(self):
        """关闭浏览器"""
        if self.browser:
            await self.browser.close()

async def main():
    """主函数 - 测试Yandex搜索"""
    print("="*60)
    print("🚀 Yandex图片搜索测试")
    print("="*60)
    
    # 测试图片URL (示例)
    test_image_url = "https://via.placeholder.com/300x300.png"
    
    # 创建搜索实例
    searcher = YandexImageSearch(headless=False)  # 设置为True可无头运行
    await searcher.init_browser()
    
    try:
        # 执行搜索
        result = await searcher.search_by_image_url(test_image_url, max_results=8)
        
        print("\n📊 搜索结果:")
        print(json.dumps(result, indent=2, ensure_ascii=False))
        
        if result["success"]:
            print(f"\n✅ 搜索成功！找到 {result['result_count']} 张相似图片")
            print(f"🌐 搜索页面: {result['search_url']}")
            
            # 保存结果
            output_file = "yandex_search_result.json"
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(result, f, ensure_ascii=False, indent=2)
            print(f"📄 结果已保存: {output_file}")
        else:
            print(f"❌ 搜索失败: {result.get('error', '未知错误')}")
            
    finally:
        await searcher.close()
        print("\n👋 浏览器已关闭")

if __name__ == "__main__":
    asyncio.run(main())