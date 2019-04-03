const winston = require('winston');

// Logs setup
const logger = winston.createLogger({

  /** Logger levels
     *   0 - error
     *   1 - warn
     *   2 - info
     *   3 - verbose
     *   4 - debug
     *   5 - silly
     */
  transports: [
    // Write logs to 'error.log'
    new winston.transports.File({
      filename: './logs/error.log',
      level: 'error',
      format: winston.format.combine(
        winston.format.timestamp({
          format: 'YYYY-MM-DD HH:mm:ss',
        }),
        winston.format.printf(info => `${info.timestamp} ${info.level}: ${info.message}`),
      ),
      handleExceptions: true,
      maxsize: 5242880, // 5MB
      maxFiles: 3,
    }),
    // Write logs to console
    new winston.transports.Console({
      level: 'silly',
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.timestamp({
          format: 'YYYY-MM-DD HH:mm:ss',
        }),
        winston.format.printf(info => `${info.timestamp} ${info.level}: ${info.message}`),
      ),
    }),
  ],
  exitOnError: false, // do not exit on handled exceptions
});

function enableErrorsStack(winstonLogger) {
  const oldLogFoo = winstonLogger.log;
  winstonLogger.log = function foo(...args) {
    if (args.length >= 2 && (args[0] === 'error' || args[0] === 'warn')) {
      if (args[1] instanceof Error) {
        args[1] = args[1].stack;
      } else {
        const error = new Error(args[1]);
        const stackArray = error.stack.split('\n');
        stackArray.splice(1, 1);
        args[1] = stackArray.join('\n');
      }
    }
    return oldLogFoo.apply(this, args);
  };
  return winstonLogger;
}

enableErrorsStack(logger);

module.exports = logger;
