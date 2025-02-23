# Use the official Nginx image
FROM nginx:alpine

# Remove the default Nginx static files and replace with our own
RUN rm -rf /usr/share/nginx/html/*

# Copy the index.html file to the Nginx web root
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
