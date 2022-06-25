# Start from the code-server Debian base image
FROM codercom/code-server:4.0.2

#USER coder
USER root
# RUN commands
#USER 1001

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

RUN apt-get update \
 && apt-get install -y sudo

RUN adduser --disabled-password --gecos '' coder
RUN adduser coder sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install unzip + rclone (support for remote filesystem)
RUN apt-get update && apt-get install -y apt-utils && apt-get install -y curl
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension esbenp.prettier-vscode

# Install apt packages:
#RUN sudo apt-get install -y ubuntu-make
USER coder

# Copy files: 
COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
