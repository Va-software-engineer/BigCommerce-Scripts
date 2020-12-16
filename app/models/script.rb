class Script < ApplicationRecord

  belongs_to :store

  def install_main_script(store)
    store_variants = HTTParty.post(
      "https://api.bigcommerce.com/stores/#{store.store_hash}/v3/content/scripts",
      headers: {
        "X-Auth-Token": store.access_token,
        "Content-Type" => "application/json"
      },
      body: {
        "name": "Main  Pinterest Script",
        "description": "Main  Pinterest Script",
        "html": main_script(store.property_id),
        "auto_uninstall": true,
        "load_method": "default",
        "location": "head",
        "visibility": "all_pages",
        "kind": "script_tag",
        "consent_category": "essential",
        "enabled": true
      }.to_json
    )
  end

  def uninstall_main_script(store)
    store_variants = HTTParty.delete(
      "https://api.bigcommerce.com/stores/#{store.store_hash}/v3/content/scripts/#{uuid}",
      headers: {
        "X-Auth-Token": store.access_token,
        "Content-Type" => "application/json"
      }
    )
  end

  def main_script(id)
    "<script type='text/javascript'>
  !function(e){if(!window.pintrk){window.pintrk=function()
  {window.pintrk.queue.push(Array.prototype.slice.call(arguments))};var
  n=window.pintrk;n.queue=[],n.version='3.0';var
  t=document.createElement('script');t.async=!0,t.src=e;var
  r=document.getElementsByTagName('script')[0];r.parentNode.insertBefore(t,r)}}
  ('https://s.pinimg.com/ct/core.js');
  pintrk('load', #{id}, { em: '{{customer.email}}', });
  var additionalDetailsObj = {};
  {{#if product.id}}
    additionalDetailsObj.product_ids = [ '{{product.id}}' ];
  console.log('product_id: {{product.id}}');
  {{/if}}
pintrk('page', additionalDetailsObj);
</script>"
  end

  def install_pixel_script(store)
    store_variants = HTTParty.post(
      "https://api.bigcommerce.com/stores/#{store.store_hash}/v3/content/scripts",
      headers: {
        "X-Auth-Token": store.access_token,
        "Content-Type" => "application/json"
      },
      body: {
        "name": "Main  Pinterest Script",
        "description": "Main  Pinterest Script",
        "html": pixel_script(store.property_id),
        "auto_uninstall": true,
        "load_method": "default",
        "location": "head",
        "visibility": "order_confirmation",
        "kind": "script_tag",
        "consent_category": "essential",
        "enabled": true
      }.to_json
    )
  end

  def uninstall_pixel_script(store)
    store_variants = HTTParty.delete(
      "https://api.bigcommerce.com/stores/#{store.store_hash}/v3/content/scripts/#{uuid}",
      headers: {
        "X-Auth-Token": store.access_token,
        "Content-Type" => "application/json"
      }
    )
  end

  def pixel_script(id)
    "<script>
  fetch('/api/storefront/order/{{checkout.order.id}}', {
  credentials: 'same-origin'
})
  .then(function(response) {
  return response.json();
})
  .then(function(orderJson) {
  var orderQty = 0;
  var lineItems = [];
  for (i = 0; i < orderJson.lineItems.physicalItems.length; i++) {
  var thisItem = orderJson.lineItems.physicalItems[i];
  orderQty += thisItem.quantity;lineItems.push({
  product_name: thisItem.name,
  product_id: thisItem.productId,
  product_price: thisItem.salePrice,
  product_quantity: thisItem.quantity
});
}
  for (i = 0; i < orderJson.lineItems.digitalItems.length; i++) {
  var thisItem = orderJson.lineItems.digitalItems[i];
  orderQty += thisItem.quantity;
  lineItems.push({
  product_name: thisItem.name,
  product_id: thisItem.productId,
  product_price: thisItem.salePrice,
  product_quantity: thisItem.quantity
});
}
  for (i = 0; i < orderJson.lineItems.giftCertificates.length; i++) {
  var thisItem = orderJson.lineItems.giftCertificates[i];
  orderQty += thisItem.quantity;
  lineItems.push({
  product_name: thisItem.name,
  product_price: thisItem.amount,
  product_quantity: thisItem.quantity
});
}
// console.log(orderQty, lineItems)
  pintrk('track', 'checkout',{
  value: orderJson.orderAmount,
  order_quantity: orderQty,
  order_id: orderJson.orderId,
  currency: orderJson.currency.code,
  line_items: lineItems
});
});
</script>"
  end

  def install_add_to_cart_script(store)
    store_variants = HTTParty.post(
      "https://api.bigcommerce.com/stores/#{store.store_hash}/v3/content/scripts",
      headers: {
        "X-Auth-Token": store.access_token,
        "Content-Type" => "application/json"
      },
      body: {
        "name": "Add to Cart Pinterest Script",
        "description": "Add to Cart Pinterest Script",
        "html": add_to_cart_script(store.property_id),
        "auto_uninstall": true,
        "load_method": "default",
        "location": "footer",
        "visibility": "storefront",
        "kind": "script_tag",
        "consent_category": "essential",
        "enabled": true
      }.to_json
    )
  end

  def uninstall_add_to_cart_script(store)
    store_variants = HTTParty.delete(
      "https://api.bigcommerce.com/stores/#{store.store_hash}/v3/content/scripts/#{uuid}",
      headers: {
        "X-Auth-Token": store.access_token,
        "Content-Type" => "application/json"
      }
    )
  end

  def add_to_cart_script(id)
    "<script>
  document.querySelector('[data-cart-item-add]').addEventListener('submit', function(event) {
    var addedProductId = event.target.product_id.value;
    var addedProductPrice =
          parseFloat(document.querySelector('[data-product-price-without-tax]').innerText.replace(/[$|€|£|¥|₩|Fr|Kr]/
    g, ''));
    var selectedCurrencyCode = (document.querySelector('[data-currency-code]')) ?
                                 document.querySelector('[data-currency-code]').getAttribute('data-currency-code') : currency_code;
    // console.log('Add to cart -> Currency:' + selectedCurrencyCode + ' ProductId:' + addedProductId + '
ProductPrice:' + addedProductPrice, event);
    pintrk('track', 'addtocart', {
      value: addedProductPrice,
      order_quantity: 1,
      currency: selectedCurrencyCode,
      product_id: addedProductId
    });
  });
</script>"
  end
end
