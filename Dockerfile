# Use the Node.js base image
FROM node:latest AS build

# Set the working directory inside the container
WORKDIR /app

COPY package.json /app
RUN mkdir /quartz && git clone https://github.com/jackyzha0/quartz.git /quartz && cd /quartz && npm install && npx quartz build
RUN npm install


FROM node:latest

EXPOSE 3000

# Install necessary tools
RUN apt-get update && apt-get install -y cron git inotify-tools && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

COPY app.js package.json /app/
COPY --from=build /quartz/ /quartz/
COPY --from=build /app/node_modules/ /app/node_modules/

# Add the cron job to run every X minutes
COPY quartz-cron /etc/cron.d/quartz-cron
RUN chmod 0644 /etc/cron.d/quartz-cron && crontab /etc/cron.d/quartz-cron

# Set environment variables for vault and output directories
ENV OUTPUT_DIR=/output
ENV VAULT_DIR=/vault
ENV TIMER=20
ENV FOLDER=/public

# Create directories
RUN mkdir -p $OUTPUT_DIR $VAULT_DIR

# Ensure the cron log file exists
RUN touch /var/log/cron.log && chmod 666 /var/log/cron.log

CMD ["node", "/app/app.js"]