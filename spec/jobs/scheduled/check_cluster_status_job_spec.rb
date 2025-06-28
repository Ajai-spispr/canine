require 'rails_helper'

RSpec.describe Scheduled::CheckClusterStatusJob do
  let(:job) { described_class.new }

  describe '#perform' do
    let!(:cluster_running) { create(:cluster, kubeconfig: "valid_kubeconfig", status: "down") }
    let!(:cluster_down)    { create(:cluster, kubeconfig: "invalid_kubeconfig", status: "running") }

    before do
      # Stub K8::Client to control can_connect? result
      allow(K8::Client).to receive(:new).with("valid_kubeconfig").and_return(double(can_connect?: true))
      allow(K8::Client).to receive(:new).with("invalid_kubeconfig").and_return(double(can_connect?: false))
    end

    it "updates status to 'running' if cluster is reachable" do
      expect { job.perform }.to change { cluster_running.reload.status }.from("down").to("running")
    end

    it "updates status to 'down' if cluster is not reachable" do
      expect { job.perform }.to change { cluster_down.reload.status }.from("running").to("down")
    end

    it "does not update status if it is already correct" do
      cluster_running.update!(status: "running")
      expect {
        job.perform
      }.not_to change { cluster_running.reload.updated_at }
    end
  end
end 