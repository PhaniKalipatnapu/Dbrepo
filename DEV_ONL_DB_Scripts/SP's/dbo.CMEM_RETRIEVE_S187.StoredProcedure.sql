/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S187]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S187]
(  
     @An_Case_IDNO					NUMERIC(6),
     @An_EventFunctionalSeq_NUMB    NUMERIC(4),
     @An_EventGlobalSeq_NUMB		NUMERIC(19),
     @An_MemberMci_IDNO				NUMERIC(10)	OUTPUT,
     @An_MemberSsn_NUMB				NUMERIC(9)	OUTPUT,
     @Ac_Last_NAME					CHAR(20)	OUTPUT ,
     @Ac_First_NAME					CHAR(16)	OUTPUT ,
	 @Ac_Middle_NAME				CHAR(20)	OUTPUT , 
     @Ac_Suffix_NAME				CHAR(4)		OUTPUT ,
     @Ad_Batch_DATE					DATE		OUTPUT ,
     @Ac_SourceBatch_CODE			CHAR(3)		OUTPUT ,
     @An_Batch_NUMB					NUMERIC(4)	OUTPUT ,
     @An_SeqReceipt_NUMB			NUMERIC(6)  OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S187
 *     DESCRIPTION       : This Procedure populates the header section of ELOG, 'Obligation Details' pop up.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/09/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SELECT @An_MemberMci_IDNO		=  NULL ,
			 @An_MemberSsn_NUMB		=  NULL ,
			 @Ac_Last_NAME			=  NULL ,
			 @Ac_First_NAME			=  NULL ,
			 @Ac_Middle_NAME		=  NULL ,
			 @Ac_Suffix_NAME		=  NULL ,
			 @Ad_Batch_DATE			=  NULL ,
			 @Ac_SourceBatch_CODE	=  NULL ,
			 @An_Batch_NUMB			=  NULL ,
			 @An_SeqReceipt_NUMB	=  NULL ;
      DECLARE
         @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A', 
         @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P'; 
        
        SELECT TOP 1 @An_MemberMci_IDNO = CM.MemberMci_IDNO, 
        		@Ac_Last_NAME			= D.Last_NAME ,
                @Ac_First_NAME			= D.First_NAME ,
				@Ac_Middle_NAME			= D.Middle_NAME ,
				@Ac_Suffix_NAME			= D.Suffix_NAME ,
        		@An_MemberSsn_NUMB		= D.MemberSsn_NUMB, 
      			@Ad_Batch_DATE			= LS.Batch_DATE, 
      			@Ac_SourceBatch_CODE	= LS.SourceBatch_CODE,
      			@An_Batch_NUMB			= LS.Batch_NUMB, 
      			@An_SeqReceipt_NUMB		= LS.SeqReceipt_NUMB
       FROM CMEM_Y1 CM 
            JOIN DEMO_Y1 D 
            ON CM.MemberMci_IDNO = D.MemberMci_IDNO
            LEFT OUTER JOIN (SELECT TOP 1 LS.Case_IDNO , 
                                          LS.Batch_DATE, 
                                          LS.SourceBatch_CODE, 
                                          LS.Batch_NUMB, 
                                          LS.SeqReceipt_NUMB
                             FROM LSUP_Y1 LS
      						 WHERE LS.Case_IDNO					= @An_Case_IDNO 
      						   AND LS.EventFunctionalSeq_NUMB	= @An_EventFunctionalSeq_NUMB 
      						   AND LS.EventGlobalSeq_NUMB		= ISNULL(@An_EventGlobalSeq_NUMB, LS.EventGlobalSeq_NUMB)
         					  ) LS
         	ON CM.Case_IDNO = LS.Case_IDNO				  
      WHERE CM.Case_IDNO = @An_Case_IDNO 
        AND CM.CaseRelationship_CODE IN( @Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPutFather_CODE)
   ORDER BY CM.CaseRelationship_CODE;
                
END; --End Of Procedure CMEM_RETRIEVE_S187


GO
