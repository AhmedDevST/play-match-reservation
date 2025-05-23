<?php

namespace App\Enums;

enum TimeSlotsStatus: string
{
    case AVAILABLE = 'available';
    case RESERVED = 'reserved';
    case MAINTENANCE = 'maintenance';
    case BLOCKED = 'blocked';
} 