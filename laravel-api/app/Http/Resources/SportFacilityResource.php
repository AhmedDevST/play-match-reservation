<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;
class SportFacilityResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'address' => $this->address,
            'description' => $this->description,
            'price_per_hour' => $this->price_per_hour,
            'rating' => $this->rating,
            'sports' => SportResource::collection($this->sports),
            'images' => SportFacilityImageResource::collection($this->images),
            'primary_image' => Storage::url($this->images->where('is_primary', true)->first()?->path),
        ];
    }
} 