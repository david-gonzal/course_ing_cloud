#Etapa1
FROM node:18-alpine as base
WORKDIR /app
COPY package*.json ./
RUN npm install

#Etapa2
FROM node:18-alpine
WORKDIR /app
COPY --from=base /app/node_modules ./node_modules   
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
