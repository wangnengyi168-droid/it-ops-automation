#!/usr/bin/env python3
"""
简单图床服务器 - 将本地图片转为公网URL
运行在: http://192.168.1.217:8000
"""

import os
import uuid
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import uvicorn

app = FastAPI(title="简单图床服务器", description="将本地图片转为公网URL")

# 创建上传目录
UPLOAD_DIR = "/tmp/image_hosting"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# 挂载静态文件目录
app.mount("/images", StaticFiles(directory=UPLOAD_DIR), name="images")

@app.get("/")
async def root():
    """根目录"""
    return {
        "service": "简单图床服务器",
        "version": "1.0",
        "endpoints": {
            "upload": "POST /upload - 上传图片",
            "get_image": "GET /images/{filename} - 获取图片",
            "status": "GET /status - 服务器状态"
        },
        "usage": "上传图片后获得公网URL，用于Yandex图片搜索"
    }

@app.get("/status")
async def status():
    """服务器状态"""
    return {
        "status": "running",
        "upload_dir": UPLOAD_DIR,
        "file_count": len(os.listdir(UPLOAD_DIR)) if os.path.exists(UPLOAD_DIR) else 0,
        "server_ip": "192.168.1.217",
        "port": 8000
    }

@app.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    """上传图片"""
    try:
        # 生成唯一文件名
        file_ext = os.path.splitext(file.filename)[1] or ".jpg"
        filename = f"{uuid.uuid4().hex}{file_ext}"
        filepath = os.path.join(UPLOAD_DIR, filename)
        
        # 保存文件
        content = await file.read()
        with open(filepath, "wb") as f:
            f.write(content)
        
        # 生成公网URL
        public_url = f"http://192.168.1.217:8000/images/{filename}"
        
        return {
            "success": True,
            "filename": filename,
            "original_name": file.filename,
            "size": len(content),
            "public_url": public_url,
            "message": "图片上传成功，可用于Yandex搜索"
        }
        
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "error": str(e),
                "message": "图片上传失败"
            }
        )

@app.post("/upload_local")
async def upload_local_image(path: str):
    """上传本地图片文件"""
    try:
        if not os.path.exists(path):
            return {
                "success": False,
                "error": f"文件不存在: {path}",
                "message": "请检查文件路径"
            }
        
        # 读取文件
        with open(path, "rb") as f:
            content = f.read()
        
        # 生成唯一文件名
        file_ext = os.path.splitext(path)[1] or ".jpg"
        filename = f"{uuid.uuid4().hex}{file_ext}"
        filepath = os.path.join(UPLOAD_DIR, filename)
        
        # 保存文件
        with open(filepath, "wb") as f:
            f.write(content)
        
        # 生成公网URL
        public_url = f"http://192.168.1.217:8000/images/{filename}"
        
        return {
            "success": True,
            "filename": filename,
            "original_path": path,
            "size": len(content),
            "public_url": public_url,
            "message": "本地图片上传成功"
        }
        
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "error": str(e),
                "message": "本地图片上传失败"
            }
        )

if __name__ == "__main__":
    print("="*60)
    print("🚀 启动简单图床服务器")
    print("="*60)
    print(f"📁 上传目录: {UPLOAD_DIR}")
    print(f"🌐 访问地址: http://192.168.1.217:8000")
    print(f"📤 上传接口: POST http://192.168.1.217:8000/upload")
    print(f"🖼️ 图片访问: http://192.168.1.217:8000/images/{{filename}}")
    print(f"📋 状态检查: GET http://192.168.1.217:8000/status")
    print("="*60)
    
    # 启动服务器
    uvicorn.run(app, host="0.0.0.0", port=8000)