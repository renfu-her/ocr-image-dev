<?php

use App\Http\Controllers\GoogleOCRController;

Route::get('google-ocr', [GoogleOCRController::class, 'index'])->name('index');
Route::post('google-ocr', [GoogleOCRController::class, 'submit'])->name('submit');
