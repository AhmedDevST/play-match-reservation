<?php

namespace App\Enums;

enum NotificationType: string
{
    case SYSTEM_NOTIFICATION = 'system_notification';
    case FRIEND_NOTIFICATION = 'friend_notification';
    case TEAM_NOTIFICATION = 'team_notification';
    case MATCH_NOTIFICATION = 'match_notification';
} 