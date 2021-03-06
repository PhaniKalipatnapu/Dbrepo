/****** Object:  StoredProcedure [dbo].[TEXC_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE  [dbo].[TEXC_UPDATE_S1]    
    ( 
     @An_MemberMci_IDNO					NUMERIC(10,0),  
     @An_Case_IDNO						NUMERIC(6,0),  
     @Ac_ExcludeIrs_INDC				CHAR(1),
     @Ac_ExcludeAdm_INDC				CHAR(1),
     @Ac_ExcludeFin_INDC				CHAR(1),  
     @Ac_ExcludePas_INDC				CHAR(1),
     @Ac_ExcludeRet_INDC				CHAR(1),  
     @Ac_ExcludeSal_INDC				CHAR(1),    
     @Ac_ExcludeVen_INDC				CHAR(1),  
     @Ac_ExcludeIns_INDC				CHAR(1),  
     @Ac_ExcludeState_CODE				CHAR(1),  
     @As_DescriptionNotes_TEXT			VARCHAR(4000), 
     @Ac_WorkerUpdate_ID				CHAR(30),   
     @An_TransactionEventSeq_NUMB	    NUMERIC(19,0), 
     @An_TransactionEventSeqold_NUMB	NUMERIC(19,0), 
     @Ad_Effective_DATE					DATE,  
     @Ad_End_DATE						DATE
    )               
AS  
  
/*  
 *     PROCEDURE NAME    : TEXC_UPDATE_S1  
 *     DESCRIPTION       : Updating a new value to the table.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 04-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN
      DECLARE @Lc_No_INDC		CHAR(1)		 ='N';
      DECLARE @Ld_High_DATE		DATE = '12/31/9999';
      DECLARE @Ld_Current_DTTM	DATETIME2(7) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
      DECLARE @Ld_Current_DATE	DATE = @Ld_Current_DTTM;
      
      UPDATE TEXC_Y1  
         SET ExcludeIrs_INDC	= ISNULL(@Ac_ExcludeIrs_INDC,@Lc_No_INDC),  
             ExcludeAdm_INDC	= @Ac_ExcludeAdm_INDC,
             ExcludeFin_INDC	= ISNULL(@Ac_ExcludeFin_INDC,@Lc_No_INDC),   
             ExcludePas_INDC	= ISNULL(@Ac_ExcludePas_INDC,@Lc_No_INDC),   
             ExcludeRet_INDC	= ISNULL(@Ac_ExcludeRet_INDC,@Lc_No_INDC),   
             ExcludeSal_INDC	= ISNULL(@Ac_ExcludeSal_INDC,@Lc_No_INDC),      
             ExcludeVen_INDC	= ISNULL(@Ac_ExcludeVen_INDC,@Lc_No_INDC),   
             ExcludeIns_INDC	= ISNULL(@Ac_ExcludeIns_INDC,@Lc_No_INDC),   
             ExcludeState_CODE	= ISNULL(@Ac_ExcludeState_CODE,@Lc_No_INDC),   
             DescriptionNotes_TEXT = @As_DescriptionNotes_TEXT,   
             BeginValidity_DATE = @Ld_Current_DATE,     
             WorkerUpdate_ID    = @Ac_WorkerUpdate_ID,   
             Update_DTTM        = @Ld_Current_DTTM,   
             TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,   
             Effective_DATE		= @Ad_Effective_DATE,   
             End_DATE			= @Ad_End_DATE             
     OUTPUT
            DELETED.MemberMci_IDNO,
            DELETED.Case_IDNO,
            DELETED.ExcludeIrs_INDC,
            DELETED.ExcludeAdm_INDC,
            DELETED.ExcludeFin_INDC,
            DELETED.ExcludePas_INDC,
            DELETED.ExcludeRet_INDC,
            DELETED.ExcludeSal_INDC,
            DELETED.ExcludeDebt_INDC,
            DELETED.ExcludeVen_INDC,
            DELETED.ExcludeIns_INDC,
            DELETED.ExcludeState_CODE,
            DELETED.DescriptionNotes_TEXT,
            DELETED.BeginValidity_DATE,
            @Ld_Current_DATE AS EndValidity_DATE,
            DELETED.WorkerUpdate_ID,
            DELETED.Update_DTTM,
            DELETED.TransactionEventSeq_NUMB,
            DELETED.Effective_DATE,
            DELETED.End_DATE
        INTO 
            TEXC_Y1
       WHERE MemberMci_IDNO   = @An_MemberMci_IDNO 
         AND Case_IDNO        = @An_Case_IDNO 
         AND EndValidity_DATE = @Ld_High_DATE
         AND EXISTS (SELECT 1 
                       FROM TEXC_Y1 WITH(READUNCOMMITTED)
					  WHERE MemberMci_IDNO   = @An_MemberMci_IDNO 
						AND Case_IDNO        = @An_Case_IDNO 
						AND EndValidity_DATE = @Ld_High_DATE
						AND TransactionEventSeq_NUMB = @An_TransactionEventSeqold_NUMB);
         
     DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
         SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
      SELECT @Ln_RowsAffected_NUMB;
END;  --End of TEXC_UPDATE_S1 

GO
