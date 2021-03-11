<?php

declare(strict_types=1);

namespace AppTest\Domain;

use Ramsey\Uuid\UuidInterface;
use Ramsey\Uuid\Uuid;

final class Entity
{
    private UuidInterface $id;

    public function __construct()
    {
        $this->id = Uuid::uuid4();
    }
}
