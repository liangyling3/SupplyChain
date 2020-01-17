<template>

  <div>
    <Card>
        <h1>供应链</h1>
        <Row style = "margin: 10px 0">
            <Col span="20">
                <Row>
                    <!-- 1.0 点击签发单据 -->
                    <Button type="primary" style="width: 100px; font-size: 13px; margin-right: 10px" @click="openGenerateReceipt">签发单据</Button>
                    <Button type="primary" style="width: 100px; font-size: 13px; margin-right: 10px" @click="openTransfer">转让单据</Button>
                    <Button type="success" style="width: 100px; font-size: 13px; margin-right: 10px" @click="openFinancing">单据融资</Button>
                    <Button type="success" style="width: 100px; font-size: 13px; margin-right: 10px" @click="openSettle">单据结算</Button>
                </Row>
            </Col>
        </Row>
    </Card>
    <!-- 表格 -->
      <Card>
      <Table border :columns="columns" :data="datalist" disabled-hover></Table>
      <div style="margin: 10px;overflow: hidden">
          <div style="float: right;">
          <Page show-total show-elevator :total="page.total" :current="page.currentPage"
                  ></Page>
          </div>
      </div>

      <!-- 签发单据 -->
      </Card>
      <!-- 3.0 isGenerateReceipt为1，则展开这个card -->
      <Modal v-model="isGenerateReceipt" title="签发单据">
          <!-- 3.0.1 GenerateReceiptForm 是一个数组 3.0.2 GenerateReceiptRules -->
          <Form :model="GenerateReceiptForm" ref="GenerateReceiptForm" :label-width="110" :rules="GenerateReceiptRules">
              <FormItem label="欠款方" prop="fromAccount" >
                  <Input  clearable v-model="GenerateReceiptForm.fromAccount" placeholder = "请输入新合同收款方"/>
              </FormItem>
              <FormItem label="收款方" prop="toAccount" >
                  <Input  clearable v-model="GenerateReceiptForm.toAccount" placeholder = "请输入新合同收款方"/>
              </FormItem>
              <FormItem label="见证方" prop="prover" >
                  <Input  clearable v-model="GenerateReceiptForm.prover" placeholder = "请输入见证该合同方"/>
              </FormItem>              
              <FormItem label="金额" prop="amount" >
                  <Input  clearable v-model="GenerateReceiptForm.amount" placeholder = "请输入转让金额"/>
              </FormItem>
          </Form>
          <div slot="footer">
            <!-- 3.0.3 点击取消 到cancelGenerateReceipt函数 -->
            <Button type="text" @click="cancelGenerateReceipt">取消</Button>
          <!-- 4.0 提交发起-->
          <Button type="primary" @click="doGenerateReceipt">确认发起</Button>
      </div>
      </Modal>
      

      <!-- 转让单据 -->
      <Modal v-model="isTransfer" title="转让单据">
          <Form :model="TransferForm" ref="TransferForm" :label-width="110" :rules="TransferRules">
              <FormItem label="单据拥有者" prop="fromAccount" >
                  <Input  clearable v-model="TransferForm.fromAccount" placeholder = "请输入该用户名称"/>
              </FormItem>
              <FormItem label="转让方" prop="toAccount" >
                  <Input  clearable v-model="TransferForm.toAccount" placeholder = "请输入该用户名称"/>
              </FormItem>
              <FormItem label="金额" prop="amount" >
                  <Input  clearable v-model="TransferForm.amount" placeholder = "请输入转让金额"/>
              </FormItem>
              <FormItem label="单据ID" prop="receiptID" >
                  <Input  clearable v-model="TransferForm.receiptID" placeholder = "请输入用于转让的凭借单据ID"/>
              </FormItem>
          </Form>
          <div slot="footer">
            <Button type="text" @click="cancelTransfer">取消</Button>
          <Button type="primary" @click="doTransfer">确认交易</Button>
      </div>
      </Modal>

      <!-- 单据融资 -->
      <Modal v-model="isFinancing" title="单据融资">
          <Form :model="FinancingForm" ref="FinancingForm" :label-width="110" :rules="FinancingRules">
              <FormItem label="单据ID" prop="receiptID" >
                  <Input  clearable v-model="FinancingForm.receiptID" placeholder = "请输入用于融资的凭借单据ID"/>
              </FormItem>
          </Form>
          <div slot="footer">
            <Button type="text" @click="cancelFinancing">取消</Button>
          <Button type="primary" @click="doFinancing">确认融资</Button>
      </div>
      </Modal>

      <!-- 单据结算 -->
      <Modal v-model="isSettle" title="单据结算">
          <Form :model="SettleForm" ref="SettleForm" :label-width="110" :rules="SettleRules">
              <FormItem label="单据ID" prop="receiptID" >
                  <Input  clearable v-model="SettleForm.receiptID" placeholder = "请输入结算的单据ID"/>
              </FormItem>
          </Form>
          <div slot="footer">
            <Button type="text" @click="cancelSettle">取消</Button>
          <Button type="primary" @click="doSettle">确认已结算</Button>
      </div>
      </Modal>
  </div>
</template>


<script>
import axios from "@/libs/api.request";
import qs from 'qs';

// Vue.prototype.$qs = qs
export default {
  data() {
    // 单据表
    return {
      columns: [
        {
          title: '单据ID',
          align: 'center',
          key: 'receiptID',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '发起者',
          align: 'center',
          key: 'fromAccount',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '收款人',
          align: 'center',
          key: 'toAccount',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '金额',
          align: 'center',
          key: 'amount',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '确认人',
          align: 'center',
          key: 'prover',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '是否已融资',
          align: 'center',
          key: 'financinged',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '是否已结算',
          align: 'center',
          key: 'settled',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '剩余价值',
          align: 'center',
          key: 'leftValue',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
        {
          title: '备注',
          align: 'center',
          key: 'ReceiptType',
          // 过滤器
          render: (h, params) => {
            let temp = params.row[params.column.key]
            if (typeof (temp) === 'undefined') {
              return h('div', '0')
            } else {
              return h('div', params.row[params.column.key])
            }
          }
        },
      ],

      // 表单校验对象
      //3.0.2 GenerateReceiptRules
      GenerateReceiptRules: {
        fromAccount: [
          { required: true, message: '欠款人不能为空', trigger: 'blur' }
        ],
        toAccount: [
          { required: true, message: '转让方（收款人）不能为空', trigger: 'blur' }
        ],
        prover: [
          { required: true, message: '见证方不能为空', trigger: 'blur' }
        ],
        amount: [
          { required: true, message: '金额不能为空', trigger: 'blur' }
        ],
      },
      TransferRules: {
        fromAccount: [
          { required: true, message: '此单据拥有者不能为空', trigger: 'blur' }
        ],
        toAccount: [
          { required: true, message: '转让方不能为空', trigger: 'blur' }
        ],
        amount: [
          { required: true, message: '金额不能为空', trigger: 'blur' }
        ],
        receiptID: [
          { required: true, message: '单据ID不能为空', trigger: 'blur' }
        ],
      },
      FinancingRules: {
        receiptID: [
          { required: true, message: '单据ID不能为空', trigger: 'blur' }
        ],
      },
      SettleRules: {
        receiptID: [
          { required: true, message: '单据ID不能为空', trigger: 'blur' }
        ],
      },
     
      page: {
        total: 10,
        currentPage: 1,
        current: 1
      },
      
      isGenerateReceipt: false,
      isTransfer: false,
      isFinancing: false,
      isSettle: false,
      GenerateReceiptForm: {},
      TransferForm: {},
      FinancingForm: {},
      SettleForm: {},
      datalist: [
      ]
    };
  },
  
  
  methods: {
    async makeTransfer2(params) {
        let self = this
        let result = {}

        console.info('param ',params)
        self.datalist.push(params)
    },
    async makeTransfer(params) {
      //不能直接使用全局变量
      let self = this
      let result = {}

      console.info('param ',params)
      await axios.request({
          url: "Transfer",
          data: params,
          headers:{
            'Content-type': 'application/x-www-form-urlencoded',
          },
          method: "post"
      }).then(function(res) {  
          console.info(res.data);  //获取控制台数据
          result = res.data
          let retCode = result.output
          self.datalist.push(params)
        
        let form = {}
        form.ReceiptType = "transfer"  
        form.receiptID = self.datalist.length+1
        form.fromAccount = this.GenerateReceiptForm.fromAccount
        form.toAccount = this.GenerateReceiptForm.toAccount
        form.amount = this.GenerateReceiptForm.amount
        form.prover = 0

        form.financinged = 0
        form.settled = 0
        form.transferRecord = []
        form.leftValue = this.GenerateReceiptForm.amount
        self.datalist.push(form)

        let form1 = {}
        form1.ReceiptType = "fresh"  
        form1.receiptID = self.datalist.length+1
        form1.fromAccount = self.datalist[this.GenerateReceiptForm.receiptID-1].fromAccount
        form1.toAccount = self.datalist[this.GenerateReceiptForm.receiptID-1].toAccount
        form1.amount = self.datalist[this.GenerateReceiptForm.receiptID-1].amount
        form1.prover = self.datalist[this.GenerateReceiptForm.receiptID-1].prover

        form1.financinged = 0
        form1.settled = 0
        form1.transferRecord = self.datalist[this.GenerateReceiptForm.receiptID-1].transferRecord.push(form.receiptID)
        form1.leftValue = self.datalist[this.GenerateReceiptForm.receiptID-1].amount-this.GenerateReceiptForm.amount
        self.datalist.push(form1)


        
      });
    },  

    //5.0
    async makeGenerateReceipt(params) {
      let self = this
      let result = {}
      console.info('param ',params)
      await axios.request({
          url: "GenerateReceipt",
          data: params,
          headers:{
            'Content-type': 'application/x-www-form-urlencoded',

          },
          method: "post"
      }).then(function(res) {
          console.info(res.data);
          result = res.data
          let retCode = result.output
          //签发单据失败  
          if(retCode = 0) {
          }
          else {
              self.datalist.push(params)
              console.info('333',result.output)
              return 1
          }
      });
    },

    async makeFinancing(params) {
      let self = this
      let result = {}
      console.info('param ',params)
      await axios.request({
          url: "Financing",
          data: params,
          headers:{
            'Content-type': 'application/x-www-form-urlencoded',
          },
          method: "post"
      }).then(function(res) {
          console.info(res.data);
          result = res.data
          let retCode = result.output
          //签发单据失败
          if(retCode[0] != 0) {
          }
          else {
              self.datalist.push(params)
              console.info('333',result.output)
              return 1
          }
      });
    },  

    async makeSettle(params) {
      let self = this
      let result = {}
      console.info('param ',params)
      await axios.request({
          url: "Settle",
          data: params,
          headers:{
            'Content-type': 'application/x-www-form-urlencoded',
          },
          method: "post"
      }).then(function(res) {
          console.info(res.data);
          result = res.data
          let retCode = result.output
          
          let form1 = {}
          form1.ReceiptType = "financing" 
          form1.receiptID = self.datalist.length+1
          form1.fromAccount = self.datalist[this.GenerateReceiptForm.receiptID-1].fromAccount
          form1.toAccount = self.datalist[this.GenerateReceiptForm.receiptID-1].toAccount
          form1.amount = self.datalist[this.GenerateReceiptForm.receiptID-1].amount
          form1.prover = self.datalist[this.GenerateReceiptForm.receiptID-1].prover

          form1.financinged = self.datalist[this.GenerateReceiptForm.receiptID-1].financinged
          form1.settled = 1
          form1.transferRecord = self.datalist[this.GenerateReceiptForm.receiptID-1].transferRecord
          form1.leftValue = 0
          self.datalist.push(form1)
          
      });
    },

    //2.0 
    openGenerateReceipt(){
      this.isGenerateReceipt = true
    },

    //4.0
    doGenerateReceipt(){
        let self = this
        this.$refs.GenerateReceiptForm.validate(async (valid) =>{ //检验表单
        if(valid){
          let content = {}
          content.ReceiptType = "new"  
          content.receiptID = self.datalist.length+1

          content.fromAccount = this.GenerateReceiptForm.fromAccount
          content.toAccount = this.GenerateReceiptForm.toAccount
          content.prover = this.GenerateReceiptForm.prover
          content.amount = this.GenerateReceiptForm.amount

          content.financinged = 0
          content.settled = 0
          content.leftValue = this.GenerateReceiptForm.amount
          content.func = 'GenerateReceipt'

          //5.0
          this.makeGenerateReceipt(content)
          
          
          this.$Message.success('签发单据成功')
          this.cancelGenerateReceipt()
        }
        else {
          this.$Message.error('请正确填写表单')
        }
      })
    },
    cancelGenerateReceipt () {
      this.$refs.GenerateReceiptForm.resetFields()
      this.GenerateReceiptForm = {}
      this.isGenerateReceipt = false
    },

    openFinancing(){
      this.isFinancing = true
    },
    doFinancing(){
        let self = this
        this.$refs.FinancingForm.validate(async (valid) =>{ //检验表单
        if(valid){
          let content = {}
          content.ReceiptType = "financing" 
          content.receiptID = this.FinancingForm.receiptID
          content.fromAccount = self.datalist[this.FinancingForm.receiptID-1].fromAccount
          content.toAccount = self.datalist[this.FinancingForm.receiptID-1].toAccount
          content.amount = self.datalist[this.FinancingForm.receiptID-1].amount
          content.prover = self.datalist[this.FinancingForm.receiptID-1].prover

          content.financinged = 1
          content.settled = self.datalist[this.FinancingForm.receiptID-1].settled
          content.func = 'Financing'
          content.leftValue = 0

          this.makeFinancing(content)
          
          this.$Message.success('单据融资成功')
          this.cancelFinancing()
        }
        else {
          this.$Message.error('请正确填写表单')
        }
      })
    },
    cancelFinancing() {
      this.$refs.FinancingForm.resetFields()
      this.FinancingForm = {}
      this.isFinancing = false
    },

    openSettle(){
      this.isSettle = true
    },
    doSettle(){
        let self = this
        this.$refs.SettleForm.validate(async (valid) =>{ //检验表单
        if(valid){
          let content = {}
          content.receiptID = this.SettleForm.receiptID
          content.func = 'Settle'

          this.makeSettle(content)
          
          
          this.$Message.success('单据结算成功')
          this.cancelSettle()
        }
        else {
          this.$Message.error('请正确填写表单')
        }
      })
    },
    cancelSettle() {
      // 重置功能添加表单对象
      this.$refs.SettleForm.resetFields()
      this.SettleForm = {}
      this.isSettle = false
    },

    //点击Transfer的确认交易
    cancelTransfer() {
      this.$refs.TransferForm.resetFields()
      this.TransferForm = {}
      this.isTransfer = false
    },
    //打开转让单据
    openTransfer() {
        this.isTransfer = true
    },
    doTransfer() {
        let self = this
        this.$refs.TransferForm.validate(async (valid) =>{ //检验表单
        if(valid){
            let content = {}
            content.ReceiptType = "transfer" 
            content.receiptID = self.datalist.length+1

            content.fromAccount = this.TransferForm.fromAccount
            content.toAccount = this.TransferForm.toAccount
            content.amount = this.TransferForm.amount

            content.prover = 0
            content.financinged = 0
            content.settled = 0
            content.leftValue = this.TransferForm.amount
            content.func = 'Transfer'

            this.makeTransfer(content)  
            this.$Message.success('转让单据成功')
            this.cancelTransfer()
        }
        else {
          this.$Message.error('请正确填写表单')
        }
      })
    }
  },
};
</script>

<style lang="css">
</style>
