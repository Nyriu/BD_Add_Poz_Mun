const express = require('express');
// const ipfilter = require('express-ipfilter').IpFilter;

const app = express();

// Whitelist the following IPs
// const ips = ['', '127.0.0.1'];
// app.use(ipfilter(ips, { mode: 'allow' }));

// Parse URL-encoded bodies (as sent by HTML forms)
app.use(express.urlencoded({ extended: true }));
// Parse JSON bodies (as sent by API clients)
app.use(express.json());

// Set the view engine to ejs
app.set('view engine', 'ejs');

// Select routes available
const routes = require('./routes');

app.use(routes);


const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0');
