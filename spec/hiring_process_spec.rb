require_relative 'spec_helper'

describe HiringProcess do
  let!(:hiring_process) { HiringProcess.new('input.txt', 'output.txt') }

  describe ".process_line(line)" do
    subject { hiring_process.send(:process_line, line) }

    context "with valid line" do
      let(:line) { "DEFINE ManualReview BackgroundCheck" }
      let(:expected_output) { ["DEFINE", "ManualReview", "BackgroundCheck"] }

      it "should return true" do
        expect(subject).to eq expected_output
      end
    end

    context "with invalid line" do
      let(:line) { "DEFINESTAGES ManualReview BackgroundCheck" }
      let(:expected_output) { "Command not found for #{line}" }

      it "should return error" do
        expect(subject).to eq expected_output
      end
    end
  end

  describe ".valid_line?(line)" do
    subject { hiring_process.send(:valid_line?,line) }

    context "with valid line" do
      let(:line) { "DEFINE ManualReview BackgroundCheck" }

      it "should return true" do
        expect(subject).to be true
      end
    end

    context "with invalid line" do
      let(:line) { "DEFINESTAGES ManualReview BackgroundCheck" }

      it "should return false" do
        expect(subject).to be false
      end
    end
  end

  describe ".wrap_error(cmd, msg = '')" do
    let(:cmd) { ["ADVANCE", "invalid_email"] }
    let(:msg) { "Email is invalid." }
    let(:expected_output) { "Error: Command #{cmd.join(' ')} is invalid. #{msg}" }

    subject { hiring_process.send(:wrap_error, cmd, msg) }

    it "should return appropriate response" do
      expect(subject).to eq expected_output
    end
  end

  describe ".is_email(str)" do
    subject { hiring_process.send(:is_email, str) }

    context "with valid email" do
      let(:str) { "john.doe@example.com" }

      it "should return true" do
        expect(subject).to be true
      end
    end

    context "with invalid email" do
      let(:str) { "invalid_email" }

      it "should return false" do
        expect(subject).to be false
      end
    end
  end

  describe ".is_at_last_stage(applicant)" do
    before do
      define_command = ["DEFINE", "ManualReview", "BackgroundCheck"]
      create_command = ["CREATE", "john.doe@example.com"]
      hiring_process.send(:define_cmd, define_command)
      hiring_process.send(:create_cmd, create_command)
    end

    subject { hiring_process.send(:is_at_last_stage, applicant) }

    context "with applicant in last stage" do
      before do
        advance_command = ["ADVANCE", "john.doe@example.com"]
        hiring_process.send(:advance_cmd, advance_command)
      end
      let(:applicant) { "john.doe@example.com" }

      it "should return true" do
        expect(subject).to be true
      end
    end

    context "with applicant not in last stage" do
      let(:applicant) { "john.doe@example.com" }

      it "should return false" do
        expect(subject).to be false
      end
    end
  end

  describe ".define_cmd(cmd)" do
    subject { hiring_process.send(:define_cmd, cmd) }

    context "with invalid cmd" do
      let(:cmd) { ["DEFINE"] }
      let(:expected_output) { "Error: Command #{cmd.join(' ')} is invalid. " }

      it "should throw error" do
        expect(subject).to eq expected_output
      end
    end

    context "with valid cmd" do
      let(:cmd) { ["DEFINE", "ManualReview", "BackgroundCheck"] }

      it "should return appropriate response" do
        expect(subject).to be cmd
      end
    end
  end

  describe ".create_cmd(cmd)" do
    subject { hiring_process.send(:create_cmd, cmd) }

    context "with invalid cmd" do
      let(:cmd) { ["CREATE", "invalid-email"] }
      let(:msg) { "Email is invalid." }
      let(:expected_output) { "Error: Command #{cmd.join(' ')} is invalid. #{msg}" }

      it "should throw error" do
        expect(subject).to eq expected_output
      end
    end

    context "with valid cmd" do
      let(:cmd) { ["CREATE", "john.doe@example.com"] }

      it "should return appropriate response" do
        expect(subject).to be cmd
      end
    end
  end

  describe ".advance_cmd(cmd)" do
    subject { hiring_process.send(:advance_cmd, cmd) }

    context "with invalid cmd" do
      let(:cmd) { ["ADVANCE"] }
      let(:expected_output) { "Error: Command #{cmd.join(' ')} is invalid. " }

      it "should throw error" do
        expect(subject).to eq expected_output
      end
    end

    context "with valid cmd" do
      before do
        define_command = ["DEFINE", "ManualReview", "BackgroundCheck"]
        create_command = ["CREATE", "john.doe@example.com"]
        hiring_process.send(:define_cmd, define_command)
        hiring_process.send(:create_cmd, create_command)
      end
      let(:cmd) { ["ADVANCE", "john.doe@example.com"] }

      it "should return appropriate response" do
        expect(subject).to be cmd
      end
    end
  end

  describe ".decide_cmd(cmd)" do
    subject { hiring_process.send(:decide_cmd, cmd) }

    context "with invalid cmd" do
      let(:cmd) { ["DECIDE", "john.doe@example.com", '1'] }
      let(:msg) { "Email does not exist in database." }
      let(:expected_output) { "Error: Command #{cmd.join(' ')} is invalid. #{msg}" }

      it "should throw error" do
        expect(subject).to eq expected_output
      end
    end

    context "with valid cmd" do
      before do
        define_command = ["DEFINE", "ManualReview", "BackgroundCheck"]
        create_command = ["CREATE", "john.doe@example.com"]
        advance_command = ["ADVANCE", "john.doe@example.com"]
        hiring_process.send(:define_cmd, define_command)
        hiring_process.send(:create_cmd, create_command)
        hiring_process.send(:advance_cmd, advance_command)
      end
      let(:cmd) { ["DECIDE", "john.doe@example.com", '1'] }
      let(:expected_output) { "Hired #{cmd[1]}" }

      it "should return appropriate response" do
        expect(subject).to eq expected_output
      end
    end
  end

  describe ".stats_cmd(cmd)" do
    subject { hiring_process.send(:stats_cmd, cmd) }

    context "with invalid cmd" do
      let(:cmd) { ["STATS", "john.doe@example.com"] }
      let(:expected_output) { "Error: Command #{cmd.join(' ')} is invalid. " }

      it "should throw error" do
        expect(subject).to eq expected_output
      end
    end

    context "with valid cmd" do
      before do
        define_command = ["DEFINE", "ManualReview", "BackgroundCheck"]
        create_command = ["CREATE", "john.doe@example.com"]
        advance_command = ["ADVANCE", "john.doe@example.com"]
        hiring_process.send(:define_cmd, define_command)
        hiring_process.send(:create_cmd, create_command)
        hiring_process.send(:advance_cmd, advance_command)
      end
      let(:cmd) { ["STATS"] }
      let(:expected_output) { "ManualReview 0 BackgroundCheck 1 Hired 0 Rejected 0" }

      it "should return appropriate response" do
        expect(subject).to eq expected_output
      end
    end
  end
end
