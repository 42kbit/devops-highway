
FROM node:14

WORKDIR /usr/src/app

COPY package*.json app.js ./

RUN npm install

ENTRYPOINT [ "" ]
CMD ["node", "app.js"]

EXPOSE 3000