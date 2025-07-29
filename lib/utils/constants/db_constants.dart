
class DbCollections{
  static const String orders      = 'orders';
  static const String products    = 'products';
  static const String users       = 'users';
  static const String categories  = 'categories';
  static const String banners     = 'banners';
  static const String addresses   = 'addresses';
  static const String meta        = 'meta_data';
  static const String purchaseList = 'purchase_list';
  static const String customers = 'customers';
  static const String vendors = 'vendors';
  static const String accounts = 'accounts';
  static const String transactions = 'transactions';
  static const String expenses = 'expenses';
  static const String accountVouchers = 'account_vouchers';
}


class PurchaseListFieldName {
  static const String id = '_id';
  static const String extraNote = 'extra_note';
  static const String lastSyncDate = 'last_sync_date';
  static const String purchasedProductIds = 'purchased_product_ids';
  static const String notAvailableProductIds = 'not_available_product_ids';
  static const String orderStatus = 'order_status';
}

class AppSettingsFieldName{
  static const String siteName = 'site_name';
  static const String siteUrl = 'site_url';
  static const String currency = 'currency';
  static const String blockedPincodes = 'blocked_pincodes';
  static const String homeBanners = 'home_banners';
}

class PurchaseListConstants {
  static const String expandedSections = 'expandedSections';
  static const String purchaseOrders = 'purchaseOrders';
}

class ProductFieldName {
  static const String id = '_id';
  static const String userId = 'user_id';
  static const String productId = 'id';
  static const String name = 'name';
  static const String mainImage = 'main_image';
  static const String permalink = 'permalink';
  static const String slug = 'slug';
  static const String dateCreated = 'date_created';
  static const String dateModified = 'date_modified';
  static const String dateOnSaleFrom = 'date_on_sale_from';
  static const String dateOnSaleTo = 'date_on_sale_to';
  static const String type = 'type';
  static const String typeVariable = 'variable';
  static const String status = 'status';
  static const String featured = 'featured';
  static const String catalogVisibility = 'catalog_visibility';
  static const String description = 'description';
  static const String shortDescription = 'short_description';
  static const String sku = 'sku';
  static const String hsnCode = 'hsn_code';
  static const String taxRate = 'tax_rate';
  static const String price = 'price';
  static const String salePrice = 'sale_price';
  static const String regularPrice = 'regular_price';
  static const String purchasePrice = 'purchase_price';
  static const String cogs = '_cogs';
  static const String brands = 'brands';
  static const String onSale = 'on_sale';
  static const String purchasable = 'purchasable';
  static const String totalSales = 'total_sales';
  static const String virtual = 'virtual';
  static const String downloadable = 'downloadable';
  static const String taxStatus = 'tax_status';
  static const String taxClass = 'tax_class';
  static const String manageStock = 'manage_stock';
  static const String stockQuantity = 'stock_quantity';
  static const String openingStock = 'opening_stock';
  static const String purchaseHistory = 'purchase_history';
  static const String weight = 'weight';
  static const String dimensions = 'dimensions';
  static const String shippingRequired = 'shipping_required';
  static const String shippingTaxable = 'shipping_taxable';
  static const String shippingClass = 'shipping_class';
  static const String shippingClassId = 'shipping_class_id';
  static const String reviewsAllowed = 'reviews_allowed';
  static const String averageRating = 'average_rating';
  static const String ratingCount = 'rating_count';
  static const String upsellIds = 'upsell_ids';
  static const String crossSellIds = 'cross_sell_ids';
  static const String parentId = 'parent_id';
  static const String purchaseNote = 'purchase_note';
  static const String categories = 'categories';
  static const String tags = 'tags';
  static const String images = 'images';
  static const String image = 'image';
  static const String attributes = 'attributes';
  static const String defaultAttributes = 'default_attributes';
  static const String variations = 'variations';
  static const String groupedProducts = 'grouped_products';
  static const String menuOrder = 'menu_order';
  static const String relatedIds = 'related_ids';
  static const String stockStatus = 'stock_status';
  static const String vendor = 'vendor';
  static const String metaData = 'meta_data';
  static const String isCODBlocked = 'easyapp_cod_blocked';
}

class ProductAttributeFieldName {
  static const String id          = 'id';
  static const String name        = 'name';
  static const String slug        = 'slug';
  static const String position    = 'position';
  static const String visible     = 'visible';
  static const String variation   = 'variation';
  static const String options     = 'options';
  static const String option     = 'option';
}

class ProductBrandFieldName {
  static const String id          = 'id';
  static const String name        = 'name';
  static const String slug        = 'slug';
  static const String image       = 'image';
  static const String parent      = 'parent';
  static const String description = 'description';
  static const String display     = 'display';
  static const String menuOrder   = 'menu_order';
  static const String count       = 'count';
  static const String permalink       = 'permalink';
}

class ReviewFieldName {
  static const String id = 'id';
  static const String dateCreated = 'date_created';
  static const String productId = 'product_id';
  static const String productName = 'product_name';
  static const String productPermalink = 'product_permalink';
  static const String status = 'status';
  static const String reviewer = 'reviewer';
  static const String reviewerEmail = 'reviewer_email';
  static const String review = 'review';
  static const String image = 'image';
  static const String rating = 'rating';
  static const String verified = 'verified';
  static const String reviewerAvatarUrls = 'reviewer_avatar_urls';
}

class CategoryFieldName {
  static const String id          = 'id';
  static const String name        = 'name';
  static const String permalink   = 'permalink';
  static const String slug        = 'slug';
  static const String image       = 'image';
  static const String parentId    = 'parentId';
  static const String isFeatured  = 'isFeatured';
}

class BannerFieldName {
  static const String imageUrl      = 'image_url';
  static const String targetPageUrl  = 'target_screen';
  static const String active        = 'active';
}

class MetaFieldName {
  static const String userCounter     = 'userCounter';
  static const String orderCounter    = 'orderCounter';
  static const String productCounter  = 'productCounter';
  static const String categoryCounter = 'categoryCounter';
  static const String value           = 'counter';
}

class OrderFieldName {
  static const String id = '_id';
  static const String wooId = 'id';
  static const String invoiceNumber = 'invoice_number';
  static const String orderId = 'order_id';
  static const String status = 'status';
  static const String currency = 'currency';
  static const String pricesIncludeTax = 'prices_include_tax';
  static const String dateCreated = 'date_created';
  static const String dateModified = 'date_modified';
  static const String discountTotal = 'discount_total';
  static const String discountTax = 'discount_tax';
  static const String shippingTotal = 'shipping_total';
  static const String shippingTax = 'shipping_tax';
  static const String cartTax = 'cart_tax';
  static const String total = 'total';
  static const String totalTax = 'total_tax';
  static const String userId = 'user_id';
  static const String user = 'user';
  static const String customerId = 'customer_id';
  static const String billing = 'billing';
  static const String shipping = 'shipping';
  static const String paymentMethod = 'payment_method';
  static const String paymentMethodTitle = 'payment_method_title';
  static const String transactionId = 'transaction_id';
  static const String customerIpAddress = 'customer_ip_address';
  static const String customerUserAgent = 'customer_user_agent';
  static const String customerNote = 'customer_note';
  static const String dateCompleted = 'date_completed';
  static const String datePaid = 'date_paid';
  static const String dateReturned = 'date_returned';
  static const String number = 'number';
  static const String metaData = 'meta_data';
  static const String lineItems = 'line_items';
  static const String shippingLines = 'shipping_lines';
  static const String couponLines = 'coupon_lines';
  static const String paymentUrl = 'payment_url';
  static const String currencySymbol = 'currency_symbol';
  static const String setPaid = 'set_paid';
  static const String purchaseInvoiceImages = 'purchase_invoice_images';
  static const String transaction = 'transaction';
  static const String orderType = 'order_type';
}

class OrderMetaDataName {
  static const String id = 'id';
  static const String key = 'key';
  static const String value = 'value';
  static const String metaData = 'meta_data';
}

class OrderMetaKeyName {
  static const String source      = '_wc_order_attribution_utm_source'; // google, facebook, androidApp
  static const String sourceType  = '_wc_order_attribution_source_type'; // organic, referral, utm, Web Admin, typein (Direct)
  static const String medium      = '_wc_order_attribution_utm_medium';  // organic, referral, utm, Web Admin, typein (Direct)
  static const String campaign    = '_wc_order_attribution_utm_campaign'; // campaign name
  static const String referrer    = '_wc_order_attribution_referrer';   // here we should use a link of referred
  static const String date        = 'date';   // Expiry time
}

class OrderStatusName {
  static const String cancelled = 'cancelled';
  static const String processing = 'processing';
  static const String readyToShip = 'readytoship';
  static const String pendingPickup = 'pending-pickup';
  static const String pendingPayment = 'pending';
  static const String inTransit = 'intransit';
  static const String completed = 'completed';
  static const String returnInTransit = 'returnintransit';
  static const String returnPending = 'returnpending';
  static const String returned = 'returned';
  static const String unknown = 'unknown';
}

class OrderStatusPritiName {
  static const String cancelled = 'Cancelled';
  static const String processing = 'Processing';
  static const String readyToShip = 'Ready To Ship';
  static const String pendingPickup = 'Pending Pickup';
  static const String pendingPayment = 'Pending Payment';
  static const String inTransit = 'In-Transit';
  static const String completed = 'Delivered';
  static const String returnInTransit = 'Return In-Transit';
  static const String returnPending = 'Return Pending';
  static const String returned = 'Returned';
}

class ExpenseTypeName {
  static const String shipping = 'Shipping';
  static const String facebookAds = 'Facebook Ads';
  static const String googleAds = 'Google Ads';
  static const String rent = 'Rent';
  static const String salary = 'Salary';
  static const String transport = 'Transport';
  static const String others = 'Others';
}

class CartFieldName {
  static const String id = 'id';
  static const String name = 'name';
  static const String userId = 'user_id';
  static const String productId = 'product_id';
  static const String variationId = 'variation_id';
  static const String quantity = 'quantity';
  static const String stockQuantity = 'stock_quantity';
  static const String category = 'category';
  static const String subtotal = 'subtotal';
  static const String subtotalTax = 'subtotal_tax';
  static const String totalTax = 'total_tax';
  static const String total = 'total';
  static const String sku = 'sku';
  static const String price = 'price';
  static const String purchasePrice = 'purchase_price';
  static const String image = 'image';
  static const String src = 'src';
  static const String hsnCode = 'hsn_code';
  static const String parentName = 'parent_name';
  static const String isCODBlocked = 'easyapp_cod_blocked';
  static const String pageSource = 'page_source';
  static const String vendor = 'vendor';
}

class StoragePath{
  static const String productsPath = 'Products/Images/';
  static const String categoryPath = 'Products/Images/';
  static const String userAvtar    = 'Users/Images/Profile/';
}

class CouponFieldName{
  static const String id = 'id';
  static const String code = 'code';
  static const String amount = 'amount';
  static const String discount = 'discount';
  static const String dateCreated = 'date_created';
  static const String discountType = 'discount_type';
  static const String description = 'description';
  static const String dateExpires = 'date_expires';
  static const String freeShipping = 'free_shipping';
  static const String individualUse = 'individual_use';
  static const String minimumAmount = 'minimum_amount';
  static const String maximumAmount = 'maximum_amount';

  static const String metaData = 'meta_data';
  static const String isCODBlocked = 'easyapp_cod_blocked';
  static const String maxDiscount = 'easyapp_max_discount';
  static const String showOnCheckout = 'easyapp_show_on_checkout';

}

class PaymentFieldName {
  static const String id = 'id';
  static const String title = 'title';
  static const String description = 'description'; // corrected
  static const String image = 'image'; // corrected
  static const String key = 'key'; // corrected
  static const String secret = 'secret'; // corrected
}

class PurchaseFieldName {
  static const String id = '_id';
  static const String purchaseID = 'purchase_id';
  static const String date = 'date';
  static const String vendor = 'vendor';
  static const String invoiceNumber = 'invoice_number';
  static const String purchasedItems = 'purchased_items';
  static const String purchaseInvoiceImages = 'purchase_invoice_images';
  static const String total = 'total';
  static const String paymentMethod = 'payment_method';
  static const String paymentAmount = 'payment_amount';
}

class PurchaseHistoryFieldName {
  static const String id = '_id';
  static const String productId = 'product_id';
  static const String purchaseId = 'purchase_id';
  static const String price = 'price';
  static const String quantity = 'quantity';
  static const String purchaseDate = 'purchase_date';
}

class AccountFieldName {
  static const String id = '_id';
  static const String userId = 'user_id';
  static const String accountId = 'account_id';
  static const String openingBalance = 'opening_balance';
  static const String balance = 'balance';
  static const String accountName = 'account_name'; // corrected
  static const String dateCreated = 'date_created'; // corrected
  static const String defaultAccount = 'default_account'; // corrected
}

class ExpenseFieldName {
  static const String id = '_id';
  static const String userId = 'user_id';
  static const String title = 'title';
  static const String expenseId = 'expense_id';
  static const String openingBalance = 'openingBalance';
  static const String description = 'description';
  static const String expenseType = 'expense_type';
  static const String account = 'account';
  static const String date = 'date';
  static const String dateCreated = 'date_created';
  static const String transaction = 'transaction';
}

class AccountVoucherFieldName {
  static const String id = '_id';
  static const String userId = 'user_id';
  static const String voucherId = 'voucher_id';
  static const String title = 'title';
  static const String openingBalance = 'opening_balance';
  static const String currentBalance = 'current_balance';
  static const String dateCreated = 'date_created';
  static const String voucherType = 'voucher_type';
}

class TransactionFieldName {
  static const String id = '_id';
  static const String userId = 'user_id';
  static const String transactionId = 'transaction_id';
  static const String date = 'date';
  static const String dateShipped = 'date_shipped';
  static const String datePaid = 'date_paid';
  static const String dateReturned = 'date_returned';
  static const String discount = 'discount';
  static const String shipping = 'shipping';
  static const String amount = 'amount';
  static const String fromAccountVoucher = 'form_account_voucher';
  static const String toAccountVoucher = 'to_account_voucher';
  static const String transactionType = 'transaction_type';
  static const String products = 'products';
  static const String status = 'status';
  static const String orderIds = 'order_ids';
  static const String couponLines = 'coupon_lines';
  static const String orderAttribute = 'order_attribute';
  static const String paymentMethod = 'payment_method';
  static const String address = 'address';
  static const String description = 'description';
}

class PaymentMethodName {
  static const String cod = 'cod';
  static const String prepaid = 'prepaid';
  static const String paytm = 'paytm';
  static const String razorpay = 'razorpay';
}

class PaymentMethodTitle {
  static const String cod = 'Cash on Delivery';
  static const String prepaid = 'Prepaid';
  static const String paytm = 'Paytm Wallet';
  static const String razorpay = 'Razorpay';
}

class UserFieldConstants {
  // Common Fields
  static const String id = '_id';
  static const String documentId = 'document_id';
  static const String userId = 'user_id';
  static const String email = 'email';
  static const String password = 'password';
  static const String role = 'role';
  static const String name = 'name';
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String fullName = 'full_name';
  static const String phone = 'phone';
  static const String avatarUrl = 'avatar_url';
  static const String dateCreated = 'date_created';
  static const String dateModified = 'date_modified';
  static const String isPayingCustomer = 'is_paying_customer';
  static const String metaData = 'meta_data';

  // Address Fields
  static const String billing = 'billing';
  static const String shipping = 'shipping';

  // Metadata Specific Fields
  static const String fCMToken = 'easyapp_fcm_token';
  static const String verifyPhone = 'easyapp_verify_phone';
  static const String isCODBlocked = 'easyapp_cod_blocked';

  // Activity Fields
  static const String activeTime = 'active_time';
  static const String cartItems = 'cart_items';
  static const String wishlistItems = 'wishlist_items';
  static const String recentItems = 'recent_items';
  static const String items = 'items';
  static const String customerOrders = 'customer_orders';
  static const String ecommercePlatform = 'ecommerce_platform';
  static const String wooCommerceCredentials = 'woo_commerce_credentials';
  static const String shopifyCredentials = 'shopify_credentials';
  static const String amazonCredentials = 'amazon_credentials';
  static const String selectedAccount = 'selected_account';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleVendor = 'vendor';
  static const String roleAdmin = 'admin';

  // Additional Fields (from both classes)
  static const String username = 'username';
  static const String company = 'company';
  static const String gstNumber = 'gst_number';
  static const String panNumber = 'pan_number';
  static const String bankAccount = 'bank_account';
  static const String balance = 'balance';
  static const String openingBalance = 'opening_balance';
  static const String userType = 'user_type';
}

class WoocommerceFieldName {
  static const String domain = 'domain';
  static const String key = 'key';
  static const String secret = 'secret';
}

class AddressFieldName {
  static const String id = 'id';
  static const String name = 'name';
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String phone = 'phone';
  static const String email = 'email';
  static const String gstNumber = 'gst_number';
  static const String address1 = 'address_1';
  static const String address2 = 'address_2';
  static const String company = 'company';
  static const String city = 'city';
  static const String state = 'state';
  static const String pincode = 'postcode';
  static const String country = 'country';
  static const String dateCreated = 'dateCreated';
  static const String dateModified = 'dateModified';
  static const String selectedAddress = 'selectedAddress';
}

class BankAccountFieldName {
  static const String bankName = 'bank_name';
  static const String accountNumber = 'account_number';
  static const String ifscCode = 'ifsc_code';
  static const String swiftCode = 'swift_code';
}

class VendorFieldName {
  static const String id = '_id';
  static const String vendorId = 'vendor_id';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String password = 'password';
  static const String name = 'first_name';
  static const String company = 'company';
  static const String gstNumber = 'gst_number';
  static const String billing = 'billing';
  static const String shipping = 'shipping';
  static const String avatarUrl = 'avatar_url';
  static const String dateCreated = 'date_created';
  static const String balance = 'balance';
  static const String openingBalance = 'opening_balance';
}
