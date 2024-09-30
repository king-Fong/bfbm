# bfbm

如何减少Dockerfile中FROM获取基础镜像的时间
答：先通过:docker pull [基础镜像]，这可以减少docker使用from命令重新从仓库拉取基础镜像的时间。