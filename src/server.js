const app = require('./app');
const config = require('../config/' + (process.env.NODE_ENV || 'development') + '.json');

const PORT = process.env.PORT || config.port || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});