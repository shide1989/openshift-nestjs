import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import Prometheus from 'prom-client';

Prometheus.collectDefaultMetrics();

export const requestHistogram = new Prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['code', 'handler', 'method'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
});

@Injectable()
export class TimerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const path = new URL(req.url, `http://${req.hostname}`).pathname;
    const stop = requestHistogram.startTimer({
      method: req.method,
      handler: path,
    });
    res.on('finish', () => {
      stop({
        code: res.statusCode,
      });
    });
    next();
  }
}
