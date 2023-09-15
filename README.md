# ocr_image

直接使用 Google Vision API 可以將圖片中的文字轉成文字檔

## 使用方式

使用 API，後端用 Laravel 開發

安裝 Google Vision API

```
composer create-project laravel/laravel
composer require google/cloud-vision
```

1. 申請網站空間 + DNS + CloudFlare
2. Laravel 更新檔案：website_developer 裏面對應的資料夾中
3. https://申請的網址/google-ocr 
