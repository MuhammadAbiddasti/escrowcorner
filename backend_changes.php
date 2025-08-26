<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ApiDeposit;
use App\Models\ApiWithdrawal;
use App\Models\Ticket;
use App\Models\Ticketcategory;
use App\Models\User;

class ApiTransactionController extends Controller
{
    // Dashboard settings API - returns dashboard image and other settings
    public function dashboardSettings(Request $request)
    {
        $user = $request->user();
        if(!empty($user))
        {
            // You can store this in database or config file
            // For now, returning a default image path
            $dashboardImage = 'assets/images/dashboard.png'; // Default image
            
            // You can make this dynamic by storing in database
            // $dashboardImage = Setting::where('key', 'dashboard_image')->value('value') ?? 'assets/images/dashboard.png';
            
            return response()->json([
                'success' => true,
                'data' => [
                    'dashboard_image' => $dashboardImage,
                    'welcome_message' => 'Welcome back!',
                    'show_create_wallet' => true
                ]
            ]);
        }
        else
        {
            return response()->json(['success' => false, 'message' => 'User not exist']);
        }
    }

    /*
     * ROUTE TO ADD IN LARAVEL ROUTES FILE (routes/api.php):
     * Route::middleware('auth:sanctum')->get('/dashboard-settings', [ApiTransactionController::class, 'dashboardSettings']);
     */

    // Updated API Deposits function with pagination support
    public function apideposits(Request $request)
    {
        $user = $request->user();
        if(!empty($user))
        {
            $user_id = isset($user->id) ? $user->id:'';
            
            // Get pagination parameters
            $perPage = $request->get('per_page', 10); // Default 10 items per page
            $page = $request->get('page', 1); // Default page 1
            
            // Get filter type if provided
            $type = $request->get('type', 'all');
            
            $query = ApiDeposit::with(['transferMethod', 'Status', 'Method'])
                ->where('user_id', $user_id);
            
            // Apply date filters based on type
            if ($type !== 'all') {
                $now = now();
                switch ($type) {
                    case 'today':
                        $query->whereDate('created_at', $now->toDateString());
                        break;
                    case 'this_week':
                        $query->whereBetween('created_at', [
                            $now->startOfWeek()->toDateTimeString(),
                            $now->endOfWeek()->toDateTimeString()
                        ]);
                        break;
                    case 'this_month':
                        $query->whereYear('created_at', $now->year)
                              ->whereMonth('created_at', $now->month);
                        break;
                    case 'this_year':
                        $query->whereYear('created_at', $now->year);
                        break;
                }
            }
            
            $deposits = $query->orderBy('created_at', 'desc')
                             ->paginate($perPage, ['*'], 'page', $page);
            
            return response()->json([
                'success' => true, 
                'data' => $deposits->items(),
                'pagination' => [
                    'current_page' => $deposits->currentPage(),
                    'last_page' => $deposits->lastPage(),
                    'per_page' => $deposits->perPage(),
                    'total' => $deposits->total(),
                    'from' => $deposits->firstItem(),
                    'to' => $deposits->lastItem(),
                ]
            ]);
        }
        else
        {
            return response()->json(['success' => false, 'message' => 'User not exist']);
        }
    }

    // Updated API Withdrawals function with pagination support
    public function apiwithdrawals(Request $request)
    {
        $user = $request->user();
        if(!empty($user))
        {
            $user_id = isset($user->id) ? $user->id:'';
            
            // Get pagination parameters
            $perPage = $request->get('per_page', 10); // Default 10 items per page
            $page = $request->get('page', 1); // Default page 1
            
            // Get filter type if provided
            $type = $request->get('type', 'all');
            
            $query = ApiWithdrawal::with(['transferMethod', 'Status', 'Method'])
                ->where('user_id', $user_id);
            
            // Apply date filters based on type
            if ($type !== 'all') {
                $now = now();
                switch ($type) {
                    case 'today':
                        $query->whereDate('created_at', $now->toDateString());
                        break;
                    case 'this_week':
                        $query->whereBetween('created_at', [
                            $now->startOfWeek()->toDateTimeString(),
                            $now->endOfWeek()->toDateTimeString()
                        ]);
                        break;
                    case 'this_month':
                        $query->whereYear('created_at', $now->year)
                              ->whereMonth('created_at', $now->month);
                        break;
                    case 'this_year':
                        $query->whereYear('created_at', $now->year);
                        break;
                }
            }
            
            $withdrawals = $query->orderBy('created_at', 'desc')
                                ->paginate($perPage, ['*'], 'page', $page);
            
            return response()->json([
                'success' => true, 
                'data' => $withdrawals->items(),
                'pagination' => [
                    'current_page' => $withdrawals->currentPage(),
                    'last_page' => $withdrawals->lastPage(),
                    'per_page' => $withdrawals->perPage(),
                    'total' => $withdrawals->total(),
                    'from' => $withdrawals->firstItem(),
                    'to' => $withdrawals->lastItem(),
                ]
            ]);
        }
        else
        {
            return response()->json(['success' => false, 'message' => 'User not exist']);
        }
    }

    public function tickets(Request $request)
    {
        $user_id = userId();
        $user = User::find($user_id);
        
        if(!empty($user))
        {
            // Get pagination parameters from request
            $page = $request->get('page', 1);
            $perPage = $request->get('per_page', 3); // Default 3 records per page
            
            // Get tickets with pagination and include category relationship
            $tickets = Ticket::where('user_id', $user->id)
                            ->with(['category', 'ticketcategory']) // Try both possible relationship names
                            ->orderBy('created_at', 'desc') // Latest tickets first
                            ->paginate($perPage, ['*'], 'page', $page);
            
            // Debug logging
            \Log::info('Tickets API Response Debug', [
                'total_tickets' => $tickets->total(),
                'current_page' => $tickets->currentPage(),
                'sample_ticket' => $tickets->items()[0] ?? null,
                'sample_ticket_category' => $tickets->items()[0]->category ?? null,
                'sample_ticket_ticketcategory' => $tickets->items()[0]->ticketcategory ?? null,
                'sample_ticket_attributes' => $tickets->items()[0]->getAttributes() ?? null,
            ]);
            
            $categories = Ticketcategory::all();
            
            return response()->json([
                'success' => true, 
                'data' => [
                    'tickets' => $tickets->items(),
                    'categories' => $categories,
                    'pagination' => [
                        'current_page' => $tickets->currentPage(),
                        'last_page' => $tickets->lastPage(),
                        'per_page' => $tickets->perPage(),
                        'total' => $tickets->total(),
                        'has_more_pages' => $tickets->hasMorePages(),
                        'from' => $tickets->firstItem(),
                        'to' => $tickets->lastItem(),
                    ]
                ]
            ]);
        }
        else
        {
            return response()->json(['success' => false, 'message' => 'User not exist']);
        }
    }
} 