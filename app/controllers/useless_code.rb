def note_for_paynotifyurl
=begin
    result = ModecPay.verify_notify(adapter,params,{:ip=>request.remote_ip })

    @payment.payment_log.update_attributes({:notify_ip=>request.remote_ip,
      :notify_params=> params.to_json,
      :notified_at=>Time.zone.now,
      :result=>result.to_json}) if @payment.payment_log

    if result.is_a?(Hash) && result.present?
      response = result.delete(:response)
      if result.delete(:payment_id) == @payment.payment_id.to_s && !@payment.paid?
        @payment.update_attributes(result)
        @order.update_attributes(:pay_status=>'1')
        Ecstore::OrderLog.new do |order_log|
          order_log.rel_id = @order.order_id
          order_log.op_id = @user.member_id
          order_log.op_name = @user.login_name
          order_log.alttime = @payment.t_payed
          order_log.behavior = 'payments'
          order_log.result = "SUCCESS"
          order_log.log_text = "订单支付成功！"
        end.save
      end
    else
      response =  result
    end
  end

=end