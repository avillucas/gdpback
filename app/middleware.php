<?php

declare(strict_types=1);

use App\Application\Middleware\SessionMiddleware;
use Slim\App;
use Slim\Views\Twig;
use Slim\Views\TwigMiddleware;

return function (App $app) {
    $app->add(SessionMiddleware::class);
    $app->add(Twig::class, function() {
        return Twig::create(__DIR__ . '/../src/Views', [
            'cache' => false,
            'debug' => true,
        ]);
    });
    $app->add(TwigMiddleware::class);
};
