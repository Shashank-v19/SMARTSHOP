package com.ecommerce.dao;

public class PaymentDAO {

    /*
     * Payment creation is currently handled inside
     * OrderDAO.placeOrder() using the same database
     * transaction.
     *
     * This class is kept separately so that a real
     * payment gateway such as Razorpay/Stripe can be
     * integrated later.
     */
}