const express = require('express');
// const ipfilter = require('express-ipfilter').IpFilter;

const app = express();

// Whitelist the following IPs
// const ips = ['', '127.0.0.1'];
// app.use(ipfilter(ips, { mode: 'allow' }));

// Set the view engine to ejs
app.set('view engine', 'ejs');

// Select routes available
const routes = require('./routes');

app.use(routes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0');
// this is a test