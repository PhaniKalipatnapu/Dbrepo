/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S37]  
	(
     @An_Case_IDNO		 				NUMERIC(6,0), 
     @Ac_IVDOutOfStateFips_CODE		 	CHAR(2),
     @Ac_IVDOutOfStateCase_ID           CHAR(15),
     @Ac_IVDOutOfStateTypeCase_CODE     CHAR(1),
     @An_TransactionEventSeq_NUMB       NUMERIC(19,0),
     @An_RespondentMci_IDNO             NUMERIC(10, 0),
     @Ac_Exists_INDC                    CHAR(1) OUTPUT   
    ) 
AS                                                         

/*
 *     PROCEDURE NAME    : ICAS_RETRIEVE_S37
 *     DESCRIPTION       : While Updating the Other State Case ID and Case Type , to check whether the previous records for the same 
                           case , state and respondent has Other state Case and Type empty or different. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN
     
     DECLARE
     
          @Lc_No_TEXT	CHAR(1)	= 'N',
          @Lc_Yes_TEXT	CHAR(1)	= 'Y', 
		  @Lc_StatusOpen_CODE	CHAR(1) = 'O' ,
          @Ld_High_DATE DATE = '12/31/9999';
         
        SET @Ac_Exists_INDC = @Lc_No_TEXT;
         
    SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT 
      FROM  ICAS_Y1 I   
     WHERE 
		 I.Case_IDNO = @An_Case_IDNO AND 
		 I.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE AND
	     I.Status_CODE		= @Lc_StatusOpen_CODE AND
		 I.EndValidity_DATE =@Ld_High_DATE AND
		 I.TransactionEventSeq_NUMB <> @An_TransactionEventSeq_NUMB AND 
		 I.RespondentMci_IDNO=@An_RespondentMci_IDNO AND
		 ((((RTRIM(LTRIM(I.IVDOutOfStateCase_ID)) = '') OR I.IVDOutOfStateCase_ID <> ISNULL(@Ac_IVDOutOfStateCase_ID,''))) OR
		 (((RTRIM(LTRIM(I.IVDOutOfStateTypeCase_CODE)) = '') OR I.IVDOutOfStateTypeCase_CODE <> ISNULL(@Ac_IVDOutOfStateTypeCase_CODE,''))))
          
END; -- END OF ICAS_RETRIEVE_S37

GO
