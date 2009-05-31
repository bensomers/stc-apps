require 'test_helper'

class ShiftMailerTest < ActionMailer::TestCase
  tests ShiftMailer
  def test_send_request
    @expected.subject = 'ShiftMailer#send_request'
    @expected.body    = read_fixture('send_request')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ShiftMailer.create_send_request(@expected.date).encoded
  end

  def test_accept
    @expected.subject = 'ShiftMailer#accept'
    @expected.body    = read_fixture('accept')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ShiftMailer.create_accept(@expected.date).encoded
  end

  def test_mail_report
    @expected.subject = 'ShiftMailer#mail_report'
    @expected.body    = read_fixture('mail_report')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ShiftMailer.create_mail_report(@expected.date).encoded
  end

end
