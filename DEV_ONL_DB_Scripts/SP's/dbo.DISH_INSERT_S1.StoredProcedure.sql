/****** Object:  StoredProcedure [dbo].[DISH_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISH_INSERT_S1](
     @An_CasePayorMCI_IDNO		 	NUMERIC(10,0),
     @Ac_TypeHold_CODE		 		CHAR(1)		 ,
     @Ac_SourceHold_CODE		 	CHAR(2)		 ,
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @Ac_ReasonHold_CODE		 	CHAR(4)		 ,
     @Ad_Effective_DATE				DATE		 ,
     @Ad_Expiration_DATE			DATE		 ,
     @An_Sequence_NUMB		 		NUMERIC(11,0)     
     )
AS

/*
 *     PROCEDURE NAME    : DISH_INSERT_S1
 *     DESCRIPTION       : Inserts the distribution hold details 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 21-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	DECLARE
		@Ld_Current_DATE	DATE 	 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ld_High_DATE 		DATE 	 = '12/31/9999',
		@Li_Zero_NUMB		SMALLINT = 0;
	INSERT DISH_Y1
            (CasePayorMCI_IDNO, 
             TypeHold_CODE,
             SourceHold_CODE, 
             EventGlobalBeginSeq_NUMB,
             ReasonHold_CODE, 
             Effective_DATE,
             Expiration_DATE, 
             Sequence_NUMB,
             EventGlobalEndSeq_NUMB, 
             BeginValidity_DATE,
             EndValidity_DATE
            )
     VALUES (@An_CasePayorMCI_IDNO, 		--CasePayorMCI_IDNO
     		 @Ac_TypeHold_CODE, 			-- TypeHold_CODE
             @Ac_SourceHold_CODE, 			--SourceHold_CODE
             @An_EventGlobalBeginSeq_NUMB, 	--EventGlobalBeginSeq_NUMB
             @Ac_ReasonHold_CODE, 			--ReasonHold_CODE
             @Ad_Effective_DATE, 			--Effective_DATE
             @Ad_Expiration_DATE, 			--Expiration_DATE
             @An_Sequence_NUMB, 			--Sequence_NUMB
             @Li_Zero_NUMB, 				--EventGlobalEndSeq_NUMB
             @Ld_Current_DATE, 				--BeginValidity_DATE
             @Ld_High_DATE  				--EndValidity_DATE
            );
                  
END;  --End of DISH_INSERT_S1


GO
