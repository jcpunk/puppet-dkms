# frozen_string_literal: true

require 'spec_helper'

describe 'dkms::autoinstall' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_exec('dkms autoinstall').with_refreshonly(true).with_timeout(600) }
    end
  end
end
