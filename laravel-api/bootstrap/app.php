<?php

use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (ValidationException $e, Request $request) {
            return response()->json([
                'success'  => false,
                'message' => 'Validation failed',
                'errors'  => $e->errors(),
            ], 422);
        });
        $exceptions->render(function (AuthenticationException $e, Request $request) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Unauthenticated',
                'errors'  => null,
            ], 401);
        });
        $exceptions->render(function (NotFoundHttpException $e, Request $request) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Resource not found',
                'errors'  => null,
            ], 404);
        });

        // Catch all other exceptions
        $exceptions->render(function (\Throwable $e, Request $request) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Something went wrong',
                'errors'  => null,
            ], 500);
        });
    })->create();
