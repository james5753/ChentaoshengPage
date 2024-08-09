const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function (app) {
  app.use(
    '/api',
    createProxyMiddleware({
      target: 'https://search-oihidiiqud.cn-shanghai.fcapp.run',
      changeOrigin: true,
    })
  );
};
