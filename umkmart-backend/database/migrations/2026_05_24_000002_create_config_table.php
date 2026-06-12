<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('config', function (Blueprint $table) {
            $table->id();
            $table->decimal('tax_rate', 5, 2)->default(0);
            $table->decimal('service_rate', 5, 2)->default(0);
            $table->string('passcode_main', 10)->default('1234');
            $table->string('passcode_admin', 10)->default('0000');
            $table->string('nama_restoran', 100)->default('UMKMART');
            $table->text('alamat')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('config');
    }
};
