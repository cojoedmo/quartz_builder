# Use the Node.js base image
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Install necessary tools
RUN apt-get update && apt-get install -y cron git inotify-tools && rm -rf /var/lib/apt/lists/*

# Copy the build script and make it executable
COPY build-quartz.sh /usr/local/bin/build-quartz.sh
RUN chmod +x /usr/local/bin/build-quartz.sh

# Add the cron job to run every X minutes
COPY quartz-cron /etc/cron.d/quartz-cron
RUN chmod 0644 /etc/cron.d/quartz-cron && crontab /etc/cron.d/quartz-cron

COPY build-quartz.js /app
COPY package.json /app

# Install npm dependencies (e.g., chokidar)
RUN ls -a
RUN npm install

# Set environment variables for vault and output directories
ENV OUTPUT_DIR=/output
ENV VAULT_DIR=/vault
ENV TIMER=20
ENV FOLDER=/public

# Create directories
RUN mkdir -p $OUTPUT_DIR $VAULT_DIR

# Ensure the cron log file exists
RUN touch /var/log/cron.log && chmod 666 /var/log/cron.log


# Start cron and keep the container running
# CMD ["bash", "-c", "/usr/local/bin/build-quartz.sh"]

# Run the file-watching script
CMD ["node", "/app/build-quartz.js"]