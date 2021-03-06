/****** Object:  StoredProcedure [dbo].[RO157_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RO157_INSERT_S1](
	@Ad_BeginFiscal_DATE		DATE,
	@Ad_EndFiscal_DATE			DATE,
	@Ac_SignedOnWorker_ID		CHAR(30),
	@Ac_LineNo_TEXT				CHAR(3),
	@An_Tot_QNTY				NUMERIC(11,2)
    )
 AS
  /*                                                                                                                                                                               
  *     PROCEDURE NAME    : RO157_INSERT_S1                                                                                                                                       
  *     DESCRIPTION       : THIS PROCEDURE IS USED TO ADD THE STAFF DETAILS FOR THE GIVEN FISCAL YEAR.
  *     DEVELOPED BY      : IMP TEAM                                                                                                                                            
  *     DEVELOPED ON      : 02-SEP-2011                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                     
 */
  BEGIN
		DECLARE
				@Li_Zero_NUMB		SMALLINT	= 0,
				@Lc_TypeReport_CODE	CHAR(1)		= 'I';  
                  
	INSERT INTO RO157_Y1
				(BeginFiscal_DATE,
				EndFiscal_DATE,
				TypeReport_CODE,
				Office_IDNO,
				County_IDNO,
				Worker_ID,
				LineNo_TEXT,
				Tot_QNTY,
				Ca_AMNT,
				Fa_AMNT,
				Na_AMNT
				)
		VALUES (@Ad_BeginFiscal_DATE,--BeginFiscal_DATE
				@Ad_EndFiscal_DATE,--EndFiscal_DATE
				@Lc_TypeReport_CODE,--TypeReport_CODE
				@Li_Zero_NUMB ,--Office_IDNO
				@Li_Zero_NUMB ,--County_IDNO
				@Ac_SignedOnWorker_ID,--Worker_ID
				@Ac_LineNo_TEXT,--LineNo_TEXT
				@An_Tot_QNTY,--Tot_QNTY
				@Li_Zero_NUMB ,--Ca_AMNT
				@Li_Zero_NUMB,--Fa_AMNT
				@Li_Zero_NUMB--Na_AMNT
				);
				
END; --End of  RO157_INSERT_S1

GO
