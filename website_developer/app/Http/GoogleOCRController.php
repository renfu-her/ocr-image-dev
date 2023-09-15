<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Google\Cloud\Vision\V1\Feature\Type;
use Google\Cloud\Vision\V1\ImageAnnotatorClient;
use Google\Cloud\Vision\V1\Likelihood;
use Google\Cloud\Vision\V1\Feature;


class GoogleOCRController extends Controller
{
    /**
     * open the view.
     *
     * @param
     * @return void
     */
    public function index()
    {
        return view('googleOcr');
    }

    /**
     * handle the image
     *
     * @param
     * @return void
     */
    public function submit(Request $request)
    {

        if ($request->hasFile('image')) {

            $imageContent = file_get_contents($request->file('image'));

            $client = new ImageAnnotatorClient([
                'credentials' => json_decode(file_get_contents(config('config.GOOGLE_CLOUD_KEY')), true)
            ]);

            $feature = (new Feature())->setType(Type::TEXT_DETECTION);
            $image = (new \Google\Cloud\Vision\V1\Image())->setContent($imageContent);

            $response = $client->annotateImage($image, [$feature]);

            $texts = $response->getTextAnnotations();
            
            return response()->json([
                'status' => 'success',
                'data' => $texts[0]->getDescription()
            ]);
        }
    }
}
