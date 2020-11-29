require 'spec_helper'

RSpec.describe "End-to-End CLI Tests" do
  subject do
    MiqVar::Cli::MainCli.new
  end
  def get_set_output(data)
    <<~OUT
     Setting State Var: string1 to #{data}
     Retries: 99 Next: 2002-10-31 02:02:02 +0200
     --------------------------------------------------
     ---
     string1: #{data}
     json1:
       a: aaa
       b: bbb
     ==================================================
    OUT
  end
  context "list" do
    it "prints a list of labels" do
      expect{ subject.list }.to output("r1234_string1:json1\nr1234_string2:json2\n").to_stdout
    end
  end
  context "show" do
    let(:show_header) do
      <<~OUT
        Task: r1234_task_id
          Root: object_type=TaskMock Id=1234
          Automate: URI=/class/instance Step=StepName
          State: 99 Retries. Next: #{Time.new(2002, 10, 31, 2, 2, 2, "+02:00")}
          User: userid (user name)/Group1
      OUT
    end
    
    def get_show_output(*vars)
      <<~OUT
      Task: r1234_task_id
        Root: object_type=TaskMock Id=1234
        Automate: URI=/class/instance Step=StepName
        State: 99 Retries. Next: #{Time.new(2002, 10, 31, 2, 2, 2, "+02:00")}
        User: userid (user name)/Group1
      --------------------------------------------------
      #{vars.join("\n")}
      ==================================================
      OUT
    end
    it "prints summary + variable-names by default" do
      expect{ subject.show("r1234_task_id") }.to output(get_show_output('string1', 'json1')).to_stdout
    end
    it "index can select a different task" do
      opts = subject.instance_variable_get(:@options)
      new_opts = opts.dup.merge({"index"=>1}).freeze
      subject.instance_variable_set(:@options, new_opts)
      expect{ subject.show("r1234_task_id") }.to output(get_show_output('string2', 'json2')).to_stdout
    end
    it "can show individual variables" do
      expect{ subject.show("r1234_task_id", "string1") }.to output(get_show_output('---', 'string1: hello world')).to_stdout
    end
  end
  context "set" do
    it "can set a variable" do
      expect{ subject.set("r1234_task_id", "string1", '"a new string"') }.to output(get_set_output("a new string")).to_stdout
    end
  end
  context "edit" do
    before(:all) do
      ENV['EDITOR'] = 'vim'
    end
    it "can edit a variable" do
      expect(MiqVar).to receive(:system).and_return(true)
      expect(File).to receive(:read).and_return("new edited value")
      expect{ subject.edit("r1234_task_id", "string1") }.to output(get_set_output("new edited value")).to_stdout
    end

    # This test launches the editor (for interactive Tests)
    # it "can edit a variable" do
    #   data = <<~OUT
    #    Setting State Var: new edited value
    #    Retries: 99 Next: 2002-10-31 02:02:02 +0200
    #    --------------------------------------------------
    #    ---
    #    string1: new edited value
    #    json1:
    #      a: aaa
    #      b: bbb
    #    ==================================================
    #   OUT
    #   # expect(MiqVar).to receive(:system).and_return(true)
    #   # expect(File).to receive(:read).and_return("new edited value")
    #   expect{ subject.edit("r1234_task_id", "json1") }.to output(data).to_stdout
    # end
  end
end