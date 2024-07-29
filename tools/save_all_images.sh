#!/bin/bash

# 获取所有镜像的列表
images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep registry.zjy.com/tsz/)

# 保存每个镜像为一个tar文件
for image in $images; do
  # 替换不合法的文件名字符
  filename=$(echo $image | tr '/:' '_')
  echo "Saving $image to $filename.tar"
  docker save -o "${filename}.tar" "$image"
done

echo "All images have been saved."

