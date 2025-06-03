<?php

namespace App\Enums;

enum TypeInvitation: string
{
    case FRIEND = 'friend';
    case TEAM = 'team';
    case MATCH = 'match';
}
