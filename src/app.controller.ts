import { Controller, Get, Res } from '@nestjs/common';
import Prometheus from 'prom-client';
import { Response } from 'express';
import { Logger } from '@nestjs/common';

import { AppService } from './app.service';

@Controller()
export class AppController {
  private readonly logger = new Logger(AppController.name);

  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    this.logger.log({ message: 'Hello from Node.js Starter Application!' });
    return 'Hello from Node.js Starter Application!';
  }
  @Get('metrics')
  async getMetrics(@Res() res: Response) {
    const metrics = await Prometheus.register.metrics();
    res.set('Content-Type', Prometheus.register.contentType);
    return metrics;
  }

  @Get('ready')
  getReady() {
    return { status: 'ok' };
  }

  @Get('live')
  getLive() {
    return { status: 'ok' };
  }
}
