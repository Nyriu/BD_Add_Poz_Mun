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

app.listen(7766, '0.0.0.0');
