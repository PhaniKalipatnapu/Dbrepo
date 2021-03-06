/****** Object:  StoredProcedure [dbo].[COMP_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[COMP_UPDATE_S2]    
(
     @An_Compliance_IDNO				NUMERIC(19,0),  
     @An_Case_IDNO						NUMERIC(6,0), 
     @An_OrderSeq_NUMB					NUMERIC(2,0),  
     @Ac_ComplianceType_CODE			CHAR(2),  
     @Ac_ComplianceStatus_CODE			CHAR(2),  
     @Ad_Effective_DATE					DATE,   
     @Ad_End_DATE						DATE,  
     @An_Compliance_AMNT				NUMERIC(11,2),  
     @Ac_Freq_CODE						CHAR(1), 
     @An_NoMissPayment_QNTY				NUMERIC(5,0), 
     @Ac_OrderedParty_CODE				CHAR(1),
     @An_TransactionEventSeq_NUMB		NUMERIC(19,0),
     @Ac_SignedOnWorker_ID				CHAR(30)
)
AS  
  
/*  
 *     PROCEDURE NAME    : COMP_UPDATE_S2  
 *     DESCRIPTION       : Updates the compliance schedule details.
 *     DEVELOPED BY      : IMP TEAM 
 *     DEVELOPED ON      : 17-JAN-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
BEGIN  
    DECLARE        
		@Li_Zero_NUMB						SMALLINT	= 0,
        @Lc_Space_TEXT						CHAR(1)		= ' ', 
        @Ld_High_DATE						DATE		= '12/31/9999',
        @Ld_Current_DATE					DATE		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
     UPDATE COMP_Y1
        SET OrderSeq_NUMB            = @An_OrderSeq_NUMB,
			ComplianceStatus_CODE    = @Ac_ComplianceStatus_CODE,
			Effective_DATE           = @Ad_Effective_DATE,
			End_DATE				 = ISNULL(@Ad_End_DATE,@Ld_High_DATE),   
            Compliance_AMNT			 = ISNULL(@An_Compliance_AMNT,@Li_Zero_NUMB),   
            Freq_CODE				 = ISNULL(@Ac_Freq_CODE,@Lc_Space_TEXT),
            NoMissPayment_QNTY		 = ISNULL(@An_NoMissPayment_QNTY,@Li_Zero_NUMB),
            BeginValidity_DATE		 = @Ld_Current_DATE,   
            EndValidity_DATE		 = @Ld_High_DATE,
            Update_DTTM				 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            WorkerUpdate_ID			 = @Ac_SignedOnWorker_ID,
            TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
            Entry_DATE				 = @Ld_Current_DATE
     OUTPUT Deleted.Compliance_IDNO ,   
            Deleted.Case_IDNO ,   
            Deleted.OrderSeq_NUMB ,   
            Deleted.ComplianceType_CODE ,   
            Deleted.ComplianceStatus_CODE ,   
            Deleted.Effective_DATE ,   
            Deleted.End_DATE,   
            Deleted.Compliance_AMNT,   
            Deleted.Freq_CODE,   
            Deleted.NoMissPayment_QNTY ,   
            Deleted.OrderedParty_CODE ,   
            Deleted.BeginValidity_DATE ,   
            @Ld_Current_DATE AS EndValidity_DATE,   
            Deleted.WorkerUpdate_ID ,   
            Deleted.Update_DTTM ,   
            Deleted.TransactionEventSeq_NUMB ,   
            Deleted.Entry_DATE   
       INTO COMP_Y1
      WHERE Case_IDNO = @An_Case_IDNO 
        AND ComplianceType_CODE = @Ac_ComplianceType_CODE 
        AND Compliance_IDNO = @An_Compliance_IDNO 
        AND OrderedParty_CODE = @Ac_OrderedParty_CODE 
        AND EndValidity_DATE = @Ld_High_DATE;
        
    DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
	    SET @Ln_RowsAffected_NUMB=@@ROWCOUNT;	  
      		      
     SELECT @Ln_RowsAffected_NUMB;  
         
END;     --End of   COMP_UPDATE_S2  


GO
